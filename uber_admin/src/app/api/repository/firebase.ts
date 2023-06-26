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
