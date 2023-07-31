"use client";

import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useQuery } from "react-query";
import * as Server from "@/local_repository/server";
import Link from "next/link";
import { useState } from "react";
import Icons from "@/svgs";

export default function Page() {
    const [user] = useAtom(userAtomAsync);
    const { data } = useQuery(["delivers"], Server.delivers, {
        suspense: true,
    });



    return <div className="max-w-3xl mx-auto  grid sm:grid-cols-3 grid-cols-1 px-2 gap-6">
        {data?.map((deliver, i) => <div className="bg-white group ring ring-stone-200 shadow rounded-lg overflow-hidden relative">

            <DropDown id={deliver.id!} />
            <div className="p-2 text-center ">
                <img className="w-20 mx-auto aspect-square rounded-full" src={deliver.photo} />
                <h2 className="font-bold my-2">{deliver.name}</h2>
                <p className="text-stone-800">{deliver.address}</p>
                <p className="text-black">{deliver.phone}</p>

            </div>

            <Link href={`/deliver_requests/${deliver.id}/details`} className="block text-center text-black font-bold group-hover:text-white group-hover:bg-black py-2 w-full">
                View
            </Link>

        </div>
        )}

    </div>
}

function DropDown(params: { id: string }) {

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
            id="dropdownMenuIconButton" data-dropdown-toggle="dropdownDots" className="absolute top-2 right-2 inline-flex items-center p-2 text-sm font-medium text-center rounded-lg text-black  hover:bg-black hover:text-white" type="button">
            <Icons.MoreVertical className="w-5 h-5" />
        </button>

        <div id="dropdownDots" className={`absolute top-10 left-10 z-10  bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600 ${!isOpen ? "hidden" : ""}`}>
            <ul className="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropdownMenuIconButton">
                <li>
                    <Link className="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white" href={`/deliver_request/${params.id}/review`}>Review</Link>

                </li>

            </ul>
        </div>

    </>

}