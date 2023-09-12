"use client"

import * as Lucide from "lucide-react"
import * as Server from "@/local_repository/server"
import Link from "next/link"
import { useQueries, useQuery } from "react-query"
import { useAtom } from "jotai"
import { realTimeAtom } from "@/state"
import { IOrder } from "@/utils/types"


export default function Page() {

    const [isRealtime] = useAtom(realTimeAtom);
    const { data } = useQuery(["report", "orders"], Server.getOrders, {
        suspense: true,
        refetchInterval: isRealtime ? false : 60 * 1000
    })


    const date = new Date();

    return <div className="max-w-2xl w-full mx-auto space-y-4 mt-8">
        {data?.map(order => <Order {...order} />)}
    </div>
}

function Order(props: IOrder) {

    const isDone = !!props.isPickup || !!props.isDelivered || false
    const isProgress = !!props.sellerPhone

    return <div className="p-2 py-3 items-center flex rounded-md bg-white">
        <div className="aspect-square w-16 flex justify-center items-center">
            <Lucide.ShoppingBag size={40} className="text-stone-900" />
        </div>

        <div className="flex-1">
            <h1 className="font-bold text-sm text-black">{props.bagName}</h1>
            <p className="text-stone-800">{props.clientPhone}
                <span className="bg-stone-300 text-sm font-medium font-mono px-2 py-0.5 uppercase">{isDone ? "finished" : isProgress ? "in progress" : ""}</span>
            </p>
        </div>

        <div className="space-x-1 text-sm">
            {!!props.sellerName && <Link href={`/seller_requests/${props.sellerID}/details`} className="px-2 py-1 rounded-md bg-black text-white">
                {props.sellerName}
            </Link>}
        </div>

    </div>
}
