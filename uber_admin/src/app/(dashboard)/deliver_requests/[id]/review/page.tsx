"use client";
import * as Lucide from "lucide-react";
import * as Server from "@/local_repository/server";
import Link from "next/link";
import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useQuery } from "react-query";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { AcceptSeller, IAcceptSeller, IDeliver } from "@/utils/types";

type Props = {
    params: {
        id: string
    }
}

export default function Page(props: Props) {


    const router = useRouter();
    const [user] = useAtom(userAtomAsync);

    const { data } = useQuery(["deliver", props.params.id], () => Server.deliver(props.params.id), {
        suspense: true,
        onError: (error) => {
            router.replace("/deliver_requests");
        }
    });

    const [deliverInfo, setDeliverInfo] = useState<IDeliver>({
        ...(data as any),
    })

    function update(){
    
    }


    return <div className="w-full max-w-3xl mx-auto -mt-4">
        <h2 className="font-bold text-black text-2xl  w-full max-w-3xl ">Deliver Profile</h2>

        <div className=" bg-white shadow-md  grid grid-cols-1 px-2   mt-6 py-2">

            <div className="p-2 border-b-2 border-dashed border-stone-500 space-y-2">
                <h2 className="font-bold  text-black text-2xl mx-auto sm:text-center">Deliver Informations</h2>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Name</label>
                    <input
                        value={deliverInfo.name}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg hover:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Photo</label>
                    <label className="relative w-full flex items-center justify-center overflow-hidden">
                        <input
                            disabled
                            type="file" className="absolute inset-0 opacity-0" />
                        {deliverInfo.photo ? <img src={deliverInfo.photo} className="absolute object-cover inset-0 " /> : null}
                        <div className="ring-2 z-50 ring-black/50 aspect-square p-2 rounded-full">
                            <Lucide.Image size={20} className="text-black" />

                        </div>
                    </label>
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Phone</label>
                    <input
                        value={deliverInfo.phone}
                        disabled
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Address</label>
                    <input
                        value={deliverInfo.address}
                        className="w-full  px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Wilaya</label>
                    <input
                        value={deliverInfo.wilaya}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Country</label>
                    <input
                        value={deliverInfo.country}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>


            </div>


        </div>
        {data?.active == false && <button className="bg-black text-white font-bold px-12 py-2 rounded-md my-4 w-full">
            Accept
        </button>}

        {data?.active == true && <button className="border-2 border-stone-600 text-black font-bold px-12 py-1.5 rounded-md my-4 w-full">
            Delete
        </button>}

    </div>

}