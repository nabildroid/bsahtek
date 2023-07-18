"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";


export default function NavButton(props: { label: string; link: string }) {
    const route = usePathname();

    const isActive = route == props.link || route.includes(props.link + "/");
    return (
        <Link
            href={props.link}
            className={`flex shrink-0 items-center space-x-3  px-3 py-1 text-black hover:border hover:bg-stone-600-500/30 transition-colors duration-300 ease-in-out  border-stone-600/40   text-sm rounded-md ${isActive && "border bg-stone-500/30"
                } `}
        >
            <span>{props.label}</span>
        </Link>
    );
}