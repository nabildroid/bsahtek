import * as Admin from "firebase-admin";

let firebase =
  Admin.apps.length === 0
    ? Admin.initializeApp({
        // deflault
        credential: process.env.FIREBASE
          ? Admin.credential.cert(JSON.parse(process.env.FIREBASE))
          : Admin.credential.applicationDefault(),
      })
    : Admin.app();
export default firebase;

export const firestore = firebase.firestore();

import { DecodedIdToken } from "firebase-admin/lib/auth/token-verifier";

export const VerificationError = (msg: string = "Not Allowed") =>
  new Response(msg, { status: 401 });
// create express middleware to verify firebase token from cookie
export const NotAllowed = async (req: Request) => {
  const AuthToken = (req.headers as any).get("authorization")?.split(" ")[1];

  const token = AuthToken || "";

  if (!token || token == "") return true;

  try {
    const decodedToken = await firebase.auth().verifyIdToken(token);

    // todo check if it's an admin, if not return error and notify the system!
    // todo check if expires

    (req as any).auth = decodedToken;
    return;
  } catch (err) {
    console.error(err);
    return true;
  }
};
