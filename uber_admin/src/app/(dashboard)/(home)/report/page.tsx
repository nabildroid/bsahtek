"use client"

import * as Lucide from "lucide-react"
import * as Server from "@/local_repository/server"
import Link from "next/link"
import { useQueries, useQuery } from "react-query"
import { useAtom } from "jotai"
import { realTimeAtom } from "@/state"
import { IOrder } from "@/utils/types"
import { useState } from "react"


export default function Page() {

    const [isRealtime] = useAtom(realTimeAtom);
    const { data } = useQuery(["report", "orders"], Server.getOrders, {
        suspense: true,
        refetchInterval: isRealtime ? false : 60 * 1000
    })

    data?.sort((a, b) => a.createdAt > b.createdAt ? -11 : 1);

    const [search, setSearch] = useState("");

    const filtredData = search.length < 2 ? data : data?.filter(i => {
        return search.includes(i.sellerName) ||
            i.sellerID.includes(search) ||
            i.sellerPhone?.includes(search) ||
            (i.bagPrice + "dz").includes(search) ||
            i.bagName.includes(search) ||
            i.clientName.includes(search) ||
            i.clientID.includes(search) ||
            i.clientPhone.includes(search) ||
            i.id.toString().includes(search)
    });


    const date = new Date();

    return <>
        <div className="max-w-2xl w-full  mt-4 sm:w-full sm:mx-auto bg-white ring-2 ring-stone-400 rounded-md px-2 py-1 mb-4 mx-2">
            <input
                value={search}
                onChange={e => setSearch(e.target.value)}
                type="text" className="bg-transparent w-full outline-none" placeholder="Search by Seller Name, Seller ID, bag name, price" />
        </div>

        <div className="relative  border border-stone-300  sm:rounded-lg mt-4 mx-2">

            <table className="w-full text-sm text-left text-stone-500">
                <thead className="text-xs text-stone-700 uppercase bg-stone-200/50 backdrop-blur-lg sticky top-0">
                    <tr>
                        <th scope="col" className="px-3 py-3">
                            ID
                        </th>
                        <th scope="col" className="px-3 py-3">
                            Date
                        </th>
                        <th scope="col" className="px-3 py-3 hidden sm:table-cell">
                            Bag
                        </th>
                        <th scope="col" className="px-3 py-3">
                            Client
                        </th>
                        <th scope="col" className="px-3 py-3 hidden sm:table-cell">
                            Delivery
                        </th>

                        

                        <th scope="col" className="px-3 py-3 hidden sm:table-cell">
                            Total
                        </th>
                    </tr>
                </thead>
                <tbody>

                    {
                        filtredData?.map(order => <tr key={order.id} className="bg-white border-b ">
                            <th scope="row" className="px-3 py-4 font-mono">
                                #{order.id.slice(0, 10)}
                            </th>
                            <td className="px-3 py-4 font-mono">
                                {new Date(order.createdAt).toLocaleString()}
                            </td>
                            <td className="px-3 py-4 hidden sm:table-cell">
                                {order.bagName}
                            </td>
                            <td className="px-3 py-4 font-medium text-stone-900 whitespace-nowrap ">
                                {order.clientName}
                            </td>
                            <td className="px-3 py-4 hidden sm:table-cell">
                                {order.deliveryName ?? order.isPickup ? 'pickup' : 'delivery'}
                            </td>
                            <td className="px-3 py-4 hidden ">
                                {/* {diffInMin(new Date(order.createdAt), new Date(order.lastUpdate))} min */}
                            </td>
                            <td className="px-3 py-4 hidden sm:table-cell">
                                {order.bagPrice}dz
                            </td>

                        </tr>)

                    }
                </tbody>
            </table>
        </div>


    </>

}