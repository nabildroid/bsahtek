"use client";


import app, { authApp } from "./firebase";
import * as Server from "./server";
import { User, getAuth, signInWithCustomToken } from "firebase/auth";
import Cookies from "js-cookie";

const AuthClient = getAuth(authApp);
const auth = getAuth(app);

export default AuthClient;

export function ListenToAuth(onUser: (user: User) => void) {
  console.log("going to fetch the token");

  console.time("Fetching Token");

  return AuthClient.onIdTokenChanged(async (user) => {
    if (user) {
      const data = await user.getIdTokenResult();

      if (!user.email?.endsWith("@bsahtek.net")) {
        AuthClient.signOut();
        Cookies.remove("token");
        Cookies.remove("isLogged");
        location.reload();
      }


      const { token } = data;
      console.log("sync token", token);

      Cookies.remove("token");
      Cookies.set("token", token, {
        path: "/",
        expires: 10000000, // todo change this
      });

      console.timeEnd("Fetching Token");
      onUser({
        ...user,
        ...data.claims,
      } as any);


      // we need to get token from the client firebase!and instanitate firebase client based on that!

      Server.auth().then(accessToken => {
        console.log("Access Token", accessToken);

        return signInWithCustomToken(auth, accessToken);
      });

    } else {
      Cookies.remove("token");
      Cookies.remove("isLogged");
      location.reload();
    }
  });
}