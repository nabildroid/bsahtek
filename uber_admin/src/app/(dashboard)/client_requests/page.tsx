"use client";

import * as Lucide from "lucide-react";
import * as Server from "@/local_repository/server";
import Link from "next/link";
import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useQuery } from "react-query";
import { IClient } from "@/utils/types";



export default function Page() {
    const [user] = useAtom(userAtomAsync);
    const { data, refetch } = useQuery(["client_requests"], Server.clientRequests, {
        suspense: true,
        refetchInterval: 1000 * 60
    });

    async function accept(demand: IClient) {
        await Server.acceptClient(demand);
        refetch();
    }

    async function reject(demand: IClient) {
        const msg = prompt("reason for rejection") || undefined;
        await Server.rejectClient({
            ...demand,
            rejectionReason: msg
        });
        refetch();
    }


    return <div className="max-w-lg mx-auto space-y-8">
        {
            data?.map((request, i) => <div key={request.id} className="p-2 py-3 items-center flex rounded-md bg-white">
                <div className="aspect-square w-16 flex justify-center items-center">
                    <Lucide.ShoppingBag size={40} className="text-stone-900" />
                </div>

                <div className="flex-1">
                    <h1 className="font-bold text-sm text-black">{request.name}</h1>
                    <p className="text-stone-800">{request.address} {" "}
                        <a href={`tel:+213${request.phone?.replaceAll(" ", "")}`} className="underline decoration-stone-800" >0{request.phone}</a>
                    </p>
                </div>

                <div className="sm:space-x-1 text-sm flex flex-col sm:flex-row space-y-2 sm:space-y-0">
                    <button
                        onClick={() => accept(request)}
                        className="px-2 py-1 rounded-md bg-black text-white">
                        Accept
                    </button>
                    <button
                        onClick={() => reject(request)}
                        className="px-2 py-1 rounded-md border bg-stone-500/30 border-stone-600/40  text-black">
                        Reject
                    </button>
                </div>


            </div>)
        }
    </div>
}