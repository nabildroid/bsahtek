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
  | "super@laknabil.me"
  | "viewer@laknabil.me"
  | "ads_editor@laknabil.me"
  | "ads_viewer@laknabil.me"
  | "seller_admin@laknabil.me"
  | "seller_accept@laknabil.me"
  | "seller_editor@laknabil.me"
  | "seller_viewer@laknabil.me"
  | "clients_admin@laknabil.me"
  | "clients_viewer@laknabil.me"
  | "analytic@laknabil.me";

type ExtractRole = GroupAccessLevel extends `${infer Role}@laknabil.me`
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

    if (!decodedToken.email?.endsWith("@laknabil.me")) return true;

    const levels = [level, "super"].flat().reverse();
    const groups = await IdentityListGroups("C045fq31n");

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
