"use client"

import UserFetcher from "@/hooks/components/userFetcher";
import { userAtom } from "@/state";
import { useAtom } from "jotai";


export default function Profile() {

    const [user] = useAtom(userAtom);

    return <>
        <UserFetcher />

        <div className="ml-2 col-span-1  w-10 rounded-full">
            {
                user?.photoURL ?
                    <img src={user.photoURL} className="rounded-full object-cover" />
                    : null
            }
        </div>
    </>

}
