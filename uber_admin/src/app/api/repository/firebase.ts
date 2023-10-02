import * as Admin from "firebase-admin";

let firebase =
  Admin.apps.find((a) => a?.name == "apps") ??
  Admin.initializeApp(
    {
      credential: process.env.FIREBASE
        ? Admin.credential.cert(JSON.parse(process.env.FIREBASE))
        : Admin.credential.applicationDefault(),
    },
    "apps"
  );

export default firebase;

export const firestore = firebase.firestore();

import { DecodedIdToken } from "firebase-admin/lib/auth/token-verifier";

export const VerificationError = (msg: string = "Not Allowed") =>
  new Response(msg, { status: 401 });
// create express middleware to verify firebase token from cookie

export const BlocForNot = async (roles: string | string[], req: Request) => {
  const AuthToken = (req.headers as any).get("authorization")?.split(" ")[1];

  // if (process.env.NODE_ENV == "development") return false;

  if (!AuthToken || AuthToken == "") return true;

  try {
    const decodedToken = await firebase.auth().verifyIdToken(AuthToken, true);

    if (
      [roles].flat().every((role) => {
        if (role == "") return false; // if authenticated without role!, sometime we need to expose route with only login need
        const [roleName, userID] = role.split("#");

        if (decodedToken.role != roleName) return true;
        if (userID && userID != decodedToken.uid) return true;
        // todo rethink about this, when the client submit a request, he doesn't have phone number till he get accepted!
        // if (roleName != "admin" && !decodedToken.phone_number) return true;
      })
    )
      return true;

    (req as any).auth = decodedToken;
    return;
  } catch (err) {
    console.error(err);
    return true;
  }
};
