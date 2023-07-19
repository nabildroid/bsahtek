"use client";
import * as Lucide from "lucide-react";
import * as Server from "@/local_repository/server";
import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useQuery } from "react-query";
import { useRouter } from "next/navigation";
import { ISellerRequest } from "@/utils/types";
import { useState } from "react";
import { IBag } from "@/types";

type Props = {
    params: {
        id: string
    }
}

export default function Page(props: Props) {

    const router = useRouter();
    const [user] = useAtom(userAtomAsync);

    const { data } = useQuery(["seller", props.params.id], () => Server.seller(props.params.id), {
        suspense: true,
        onError: (error) => {
            router.replace("/seller_requests");
        }
    });


    const bag = data?.bags[0];


    const [sellerInfo, setSellerInfo] = useState<ISellerRequest>({
        id: props.params.id,
        ...data!.seller
    });

    const [bagInfo, setBagInfo] = useState<IBag>({
        ...(bag as any)

    });


    return <div className="w-full max-w-3xl mx-auto -mt-4">
        <h2 className="font-bold text-black text-2xl  w-full max-w-3xl ">Assing Seller to Bag</h2>

        <div className=" bg-white shadow-md  flex  flex-col items-start  sm:flex-row px-2   my-6">


            <div className="p-2 pb-24 sm:border-r-2 border-dashed border-stone-500 space-y-2">
                <h2 className="font-bold  text-black text-2xl mx-auto sm:text-center">Seller</h2>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Name</label>
                    <input
                        value={sellerInfo.name}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, name: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller phone</label>
                    <input disabled
                        value={sellerInfo.phone}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, phone: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Country</label>
                    <input
                        value={sellerInfo.country}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, country: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Wilaya</label>
                    <input
                        value={sellerInfo.wilaya}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, wilaya: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>


                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Address</label>
                    <input
                        value={sellerInfo.address}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, address: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Store name</label>
                    <input
                        value={sellerInfo.storeName}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, storeName: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Store address</label>
                    <input
                        value={sellerInfo.storeAddress}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, storeAddress: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>



                <div className="p-2 rounded-lg hover:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Photo</label>
                    <label className="relative overflow-hidden w-full flex items-center justify-center">
                        <input type="file" className="absolute inset-0 opacity-0" />
                        {sellerInfo.photo ? <img src={sellerInfo.photo} className="absolute object-cover inset-0 " /> : null}
                        <div className="ring-2 z-50 ring-black/50 aspect-square p-2 rounded-full">
                            <Lucide.Image size={20} className="text-black" />
                        </div>
                    </label>
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Store Type</label>
                    <input
                        value={sellerInfo.storeType}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, storeType: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>


                <button className="border-2 border-stone-600 text-black font-bold px-12 py-1.5 rounded-md my-4 w-full">
                    Delete
                </button>
            </div>

            <div className="p-2 space-y-2 sticky top-20">
                <h2 className="font-bold text-black text-2xl mx-auto sm:text-center">Bag</h2>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Name</label>
                    <input
                        value={bagInfo.name}
                        onChange={(e) => setBagInfo({ ...bagInfo, name: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Price</label>
                    <input
                        value={bagInfo.price}
                        onChange={(e) => setBagInfo({ ...bagInfo, price: Number(e.target.value) })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Original Price</label>
                    <input
                        value={bagInfo.originalPrice}
                        onChange={(e) => setBagInfo({ ...bagInfo, originalPrice: Number(e.target.value) })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg hover:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Photo</label>
                    <label className="relative w-full flex items-center justify-center">
                        <input type="file" className="absolute inset-0 opacity-0" />

                        {bagInfo.photo ? <img src={bagInfo.photo} className="absolute object-cover inset-0 " /> : null}
                        <div className="ring-2 z-50 ring-black/50 aspect-square p-2 rounded-full">
                            <Lucide.Image size={20} className="text-black" />
                        </div>
                    </label>
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Tags</label>
                    <input
                        value={(bagInfo.tags as any) ?? ""}
                        onChange={(e) => setBagInfo({ ...bagInfo, tags: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <button className="bg-black text-white font-bold px-12 py-2 rounded-md my-4 w-full">
                    Assign
                </button>

            </div>



        </div>


    </div>

}