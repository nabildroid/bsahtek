"use client"

import { userAtomAsync } from "@/state";
import Icons from "@/svgs";
import { useAtom } from "jotai";
import * as Server from "@/local_repository/server";
import { useQuery } from "react-query"
import Link from "next/link";

type Props = {
    children: React.ReactNode;
}

export default function Layout(props: Props) {

    const [user] = useAtom(userAtomAsync);
    const { data } = useQuery(["sellers"], Server.sellers, {
        suspense: true,
    });

    return <div className="max-w-6xl mx-auto">
        {props.children}

        <div className="grid grid-cols-1 px-2 sm:grid-cols-2 lg:grid-cols-4 gap-6  mt-8">

            {data?.map((bag, i) => <div key={bag.id} className=" group shadow-md bg-white ring ring-stone-200 rounded-lg overflow-hidden">
                <div className="p-2" >

                    <img src={bag.photo} className="object-cover w-full rounded-lg h-16" />

                    <div className="-mt-16">
                        <div className="flex items-center p-2">
                            <img src={bag.sellerPhoto} className="w-10 h-10 rounded-full object-cover ring ring-white" />

                            <div className="flex-1" />

                        </div>
                    </div>
                    <div className="p-2">
                        {/* add price:56$, store name:.., location, phonenumber  */}
                        <h2 className="text-lg font-bold">{bag.sellerName}</h2>
                        <p className="text-sm text-gray-500">{bag.name} <b>{bag.price}$</b> <span>+25655645666</span></p>
                    </div>

                </div>
                <Link href={`/seller_requests/${bag.sellerID}/assign`} className="block text-center text-black font-bold group-hover:text-white  group-hover:bg-black py-2 w-full">
                    Edit
                </Link>

            </div>
            )}
        </div>
        <div className="text-center mt-8">
            {/* <button className="px-8 text-white py-2 bg-black rounded-md mx-auto ">
                Load more
            </button> */}
        </div>


    </div>
}