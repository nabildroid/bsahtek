"use client";

import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useQuery } from "react-query";
import * as Server from "@/local_repository/server";
import Link from "next/link";

export default function Page() {
    const [user] = useAtom(userAtomAsync);
    const { data } = useQuery(["delivers"], Server.delivers, {
        suspense: true,
    });



    return <div className="max-w-3xl mx-auto  grid sm:grid-cols-3 grid-cols-1 px-2 gap-6">
        {data?.map((deliver, i) => <div className="bg-white group ring ring-stone-200 shadow rounded-lg overflow-hidden">
            <div className="p-2 text-center ">
                <img className="w-20 mx-auto aspect-square rounded-full" src={deliver.photo} />
                <h2 className="font-bold my-2">{deliver.name}</h2>
                <p className="text-stone-800">{deliver.address}</p>
                <p className="text-black">{deliver.phone}</p>

            </div>

            <Link href={`/deliver_requests/${deliver.id}/review`} className="block text-center text-black font-bold group-hover:text-white group-hover:bg-black py-2 w-full">
                view
            </Link>

        </div>
        )}

    </div>
}