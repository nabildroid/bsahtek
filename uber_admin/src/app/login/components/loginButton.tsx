"use client";
import { getAuth, getRedirectResult, GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import {authApp} from "@/local_repository/firebase";
import { useRef } from "react";
import { setLoginToken } from "@/utils";
import { useRouter } from "next/navigation";
import Cookies from "js-cookie";

export default function LoginButton() {
    const router = useRouter();


    const auth = useRef(getAuth(authApp));



    async function login() {
        // Sign in using a redirect.
        const provider = new GoogleAuthProvider();
        // Start a sign in process for an unauthenticated user.
        provider.addScope('profile');
        provider.addScope('email');
        const result = await signInWithPopup(auth.current, provider);


        if (result) {
            // This is the signed-in user
            const user = result.user;
            // This gives you a Google Access Token.
            const credential = GoogleAuthProvider.credentialFromResult(result);

            if (credential) {

                Cookies.remove("token");
                Cookies.set("token", credential.accessToken!, {
                    path: "/",
                    expires: 10000000, // todo change this
                });
                router.replace("/");


                const profile = credential.providerId;
                console.log(profile);
            }
        }

    }


    return <button onClick={login} className="mt-12 w-full bg-black text-white font-medium py-2 rounded-sm">
        Login with Google
    </button>;

}
