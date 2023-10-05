import * as Admin from "firebase-admin";
import * as Identity from "./identity_toolkit";

import { unstable_cache as cache } from "next/cache";

const IdentityListGroups = cache(Identity.listGroups, ["groups"], {
  revalidate: 1000 * 60,
});

let adminFirebase =
  Admin.apps.find((a) => a?.name == "admin") ??
  Admin.initializeApp(
    {
      credential: process.env.GOOGLE_ADMIN_FIREBASE
        ? Admin.credential.cert(JSON.parse(process.env.GOOGLE_ADMIN_FIREBASE))
        : Admin.credential.applicationDefault(),
    },
    "admin"
  );

export const VerificationError = (msg: string = "Not Allowed") =>
  new Response(msg, { status: 401 });
// create express middleware to verify firebase token from cookie

type GroupAccessLevel =
  | "@bsahtek.net"
  | "super@bsahtek.net"
  | "viewer@bsahtek.net"
  | "ads_editor@bsahtek.net"
  | "ads_viewer@bsahtek.net"
  | "seller_admin@bsahtek.net"
  | "seller_accept@bsahtek.net"
  | "seller_editor@bsahtek.net"
  | "seller_viewer@bsahtek.net"
  | "clients_admin@bsahtek.net"
  | "clients_viewer@bsahtek.net"
  | "analytic@bsahtek.net";

type ExtractRole = GroupAccessLevel extends `${infer Role}@bsahtek.net`
  ? Role
  : never;

export const AdminBlocForNot = async (
  level: ExtractRole | ExtractRole[],
  req: Request
) => {
  const AuthToken = (req.headers as any).get("authorization")?.split(" ")[1];

  // if (process.env.NODE_ENV == "development") return false;

  if (!AuthToken || AuthToken == "") return true;

  try {
    const decodedToken = await adminFirebase
      .auth()
      .verifyIdToken(AuthToken, true);

    if (!decodedToken.email?.endsWith("@bsahtek.net")) return true;

    const levels = [level, "super"].flat().reverse();
    const groups = await IdentityListGroups("C02dg8bdg");

    const groupIds = levels
      .map((l) => {
        return groups.find((g) => g.groupKey.id.startsWith(l + "@"))?.name;
      })
      .filter(Boolean);

    let isAllowed = false;
    for (const groupId of groupIds) {
      if (await Identity.checkMembership(groupId!, decodedToken.email!)) {
        isAllowed = true;
        break;
      }
    }

    if (!isAllowed) return true;

    (req as any).auth = decodedToken;
    return;
  } catch (err) {
    console.error(err);
    return true;
  }
};
