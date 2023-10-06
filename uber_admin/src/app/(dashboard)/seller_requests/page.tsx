"use client";

import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import * as Lucide from "lucide-react";
import Link from "next/link";
import { useQuery } from "react-query";
import * as Server from "@/local_repository/server";

export default function Page() {
    const [user] = useAtom(userAtomAsync);
    const { data } = useQuery(["seller_requests"], Server.sellerRequests, {
        suspense: true,
    });

    return <div className="max-w-lg mx-auto space-y-8">
        <div className="p-2  mx-4 sm:mx-auto py-1 items-center flex rounded-md bg-white border-2 border-dashed border-stone-600  overflow-hidden shadow-md">
            <div className="aspect-square w-16 flex justify-center items-center">
                <Lucide.LucideStore size={40} className="text-stone-900" />
            </div>

            <div className="flex-1">
                <h1 className="font-bold text-sm text-black">Add New Seller</h1>

            </div>

            <div className="space-x-1 text-sm">
                <Link href={`/seller_requests/new`} className="px-2 py-1 rounded-md bg-black text-white">
                    New
                </Link>

            </div>
        </div>

        {data?.map((request, i) => <div key={request.id} className="p-2 py-3 items-center flex rounded-md bg-white">
            <div className="aspect-square w-16 flex justify-center items-center">
                <Lucide.LucideStore size={40} className="text-stone-900" />
            </div>

            <div className="flex-1">
                <h1 className="font-bold text-sm text-black">{request.storeName}</h1>
                <p className="text-stone-800">{request.country}, {request.address}  {' '}
                    <a href={`tel:+213${request.phone.replaceAll(" ", "")}`} className="underline decoration-stone-800" >0{request.phone}</a>
                </p>
            </div>

            <div className="space-x-1 text-sm">
                <Link href={`/seller_requests/${request.id}/assign`} className="px-2 py-1 rounded-md bg-black text-white">
                    Review
                </Link>

            </div>

        </div>)}
    </div>
}