"use client"


import { userAtomAsync } from "@/state";
import Icons from "@/svgs";
import { useAtom } from "jotai";
import * as Server from "@/local_repository/server";
import { useQuery } from "react-query"
import Link from "next/link";
import Image from "next/image";
import { useState } from "react";

type Props = {
    children: React.ReactNode;
}

export default function Layout(props: Props) {



    const [user] = useAtom(userAtomAsync);
    const { data, refetch } = useQuery(["sellers"], Server.sellers, {
        suspense: true,
    });

    const [search, setSearch] = useState("");

    const filtredData = search.length < 2 ? data : data?.filter(i => {
        return search.includes(i.sellerName) ||
            i.sellerID.includes(search) ||
            (i.price + "dz").includes(search) ||
            i.sellerPhone?.includes(search) ||
            i.name.includes(search) ||
            i.rating.toString().includes(search) ||
            i.tags.includes(search) ||
            i.category.includes(search) ||
            i.id.toString().includes(search)
    });


    async function remove(id: string) {
        if (!confirm("going to delete the seller!")) return;
        await Server.removeSeller(id);
        refetch()
    }

    return <div className="max-w-6xl mx-auto">
        {props.children}

        <div className="max-w-md sm:w-full sm:mx-auto bg-white ring-2 ring-stone-400 rounded-md px-2 py-1 mb-4 mx-2">
            <input
                value={search}
                onChange={e => setSearch(e.target.value)}
                type="text" className="bg-transparent w-full outline-none" placeholder="Search by Seller Name, Seller ID, bag name, price" />
        </div>



        <div className="grid grid-cols-1 px-2 sm:grid-cols-2 lg:grid-cols-4 gap-6  mt-8">

            {filtredData?.map((bag, i) => <div key={bag.id} className=" group shadow-md bg-white ring ring-stone-200 rounded-lg overflow-hidden flex flex-col">

                <div className="p-2 flex-1" >

                    <Image alt="bag photo" width={400} height={180} loading="lazy" src={bag.photo} className="object-cover w-full rounded-lg h-16" />

                    <div className="-mt-16">
                        <div className="flex items-center p-2 relative">
                            <Image alt="sellerPhoto" width={50} height={50} loading="lazy" src={bag.sellerPhoto} className="w-10 h-10 rounded-full object-cover ring ring-white" />

                            <div className="flex-1" />
                            <DropDown id={bag.sellerID} onDelete={() => remove(bag.sellerID)} />

                        </div>
                    </div>
                    <div className="p-2">
                        {/* add price:56$, store name:.., location, phonenumber  */}
                        <h2 className="text-lg font-bold">{bag.sellerName}</h2>
                        <p className="text-sm text-gray-500">{bag.name} <b>{bag.price}dz</b> <span>{bag.sellerPhone}</span></p>
                    </div>

                </div>
                <Link href={`/seller_requests/${bag.sellerID}/details`} className="block text-center text-black font-bold group-hover:text-white  group-hover:bg-black py-2 w-full">
                    View
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




function DropDown(params: { id: string, onDelete: () => void }) {

    const [isOpen, setIsOpen] = useState(false);

    function toggle() {
        if (isOpen) {
            setIsOpen(false);
        } else {
            setIsOpen(true);
            setTimeout(() => {
                setIsOpen(false);
            }, 10000);
        }

    }

    return <>
        <button
            onClick={toggle}
            id="dropdownMenuIconButton" data-dropdown-toggle="dropdownDots" className="inline-flex items-center p-2 text-sm font-medium text-center rounded-lg text-white bg-black/40 hover:bg-white hover:text-black" type="button">
            <Icons.MoreVertical className="w-5 h-5" />
        </button>

        <div id="dropdownDots" className={`absolute top-10 left-10 z-10  bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600 ${!isOpen ? "hidden" : ""}`}>
            <ul className="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropdownMenuIconButton">
                <li>
                    <Link className="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white" href={`/seller_requests/${params.id}/assign`}>Edit</Link>
                </li>
                <li>
                    <button onClick={params.onDelete} className="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white" >Delete</button>
                </li>

            </ul>
        </div>

    </>

}