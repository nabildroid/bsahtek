"use client";

import { ListenToAuth } from "@/local_repository/auth";
import { userAtom } from "@/state";
import { useAtom } from "jotai";
import { useEffect } from "react";

export default function UserFetcher() {
    const [, setUser] = useAtom(userAtom);

    useEffect(() => {
        if (!ListenToAuth) return;
        const unsubscribe = ListenToAuth(
            (user) => {
                setUser(user);
            }
        );

        return unsubscribe;
    }, [setUser, ListenToAuth]);

    return <></>;
}