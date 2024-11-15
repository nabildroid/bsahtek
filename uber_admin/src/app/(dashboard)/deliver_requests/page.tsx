"use client";

import * as Lucide from "lucide-react";
import * as Server from "@/local_repository/server";
import Link from "next/link";
import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useQuery } from "react-query";
import useUploadImage from "@/hooks/useUploadImage";



export default function Page() {
    const [user] = useAtom(userAtomAsync);
    const { data } = useQuery(["deliver_requests"], Server.deliverRequests, {
        suspense: true,
    });



    return <div className="max-w-lg mx-auto space-y-8">
        {
            data?.map((request, i) => <div key={request.id} className="p-2 py-3 items-center flex rounded-md bg-white">
                <div className="aspect-square w-16 flex justify-center items-center">
                    <Lucide.Car size={40} className="text-stone-900" />
                </div>

                <div className="flex-1">
                    <h1 className="font-bold text-sm text-black">{request.name}</h1>
                    <p className="text-stone-800">{request.country} {request.address} {request.phone}</p>
                </div>

                <div className="space-x-1 text-sm">
                    <Link href={`/deliver_requests/${request.id}/review`} className="px-2 py-1 rounded-md bg-black text-white">
                        Review
                    </Link>
                    <button className="px-2 py-1 rounded-md border bg-stone-500/30 border-stone-600/40  text-black">
                        Delete
                    </button>
                </div>


            </div>)
        }
    </div>
}