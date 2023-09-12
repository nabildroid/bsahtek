"use client";

import app from "./firebase";
import { User, getAuth } from "firebase/auth";
import Cookies from "js-cookie";

const AuthClient = getAuth(app);

export default AuthClient;

export function ListenToAuth(onUser: (user: User) => void) {
  console.log("going to fetch the token");

  console.time("Fetching Token");

  return AuthClient.onIdTokenChanged(async (user) => {
    if (user) {
      const data = await user.getIdTokenResult();
      console.log("claims", data.claims);
      if (data.claims.admin != true) {
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

    } else {
      Cookies.remove("token");
      Cookies.remove("isLogged");
      location.reload();
    }
  });
}