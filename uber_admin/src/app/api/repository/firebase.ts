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

export const BlocForNot = async (role: string | string[], req: Request) => {
  const AuthToken = (req.headers as any).get("authorization")?.split(" ")[1];

  const token = AuthToken || "";

  // console.log({ token });

  if (process.env.NODE_ENV == "development") return false;

  if (!token || token == "") return true;

  return false;

  try {
    const decodedToken = await firebase.auth().verifyIdToken(token, true);

    if (
      [role].flat().every((role) => {
        // check the custom claims role
        if ((role = "")) return false;
        const [roleName, userID] = role.split("#");

        if (decodedToken.role != roleName) return true;
        if (userID && userID != decodedToken.uid) return true;
        if (roleName != "admin" && !decodedToken.phone_number) return true;
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
