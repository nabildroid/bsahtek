"use client"

import { cn } from "@/lib/utils";
import { realTimeAtom } from "@/state";
import { useAtom } from "jotai";
import Link from "next/link";
import React from "react";



export default function Layout(props: { children: React.ReactNode }) {


    const [isRealtime, setIsRealtime] = useAtom(realTimeAtom);
    return <>
        <div className="max-w-2xl w-full mx-auto">

            <div className="flex items-center  mx-1">
                <Link href="/" className="outline-none ring-black  ring-2 px-4 bg-transparent py-1 rounded-md text-black font-bold text-sm">
                    Overview
                </Link>

                <Link href="/report" className="ml-2 outline-none ring-black  ring-2 px-4 bg-transparent py-1 rounded-md text-black font-bold text-sm">
                    Report
                </Link>


                <button className={cn(
                    "ml-auto outline-none ring-black duration-300 ease-in-out  ring-2 px-4 bg-transparent py-1 rounded-md text-black font-bold text-sm"
                    , isRealtime && "no-underline  text-white bg-black hover:line-through hover:bg-transparent hover:text-black"
                    , !isRealtime && "line-through hover:no-underline text-black hover:bg-black hover:text-white"
                )} onClick={() => setIsRealtime(a => !a)}>
                    Near Realtime
                </button>

            </div>
        </div>

        {props.children}
    </>
}