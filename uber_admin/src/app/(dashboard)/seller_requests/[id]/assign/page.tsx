"use client";
import * as Lucide from "lucide-react";
import * as Server from "@/local_repository/server";
import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useQuery } from "react-query";
import { useRouter } from "next/navigation";
import { AcceptSeller, ISeller, IAcceptSeller } from "@/utils/types";
import { useState } from "react";
import { IBag } from "@/types";

import useUploadImage from "@/hooks/useUploadImage";


type Props = {
    params: {
        id: string
    }
}

export default function Page(props: Props) {

    const uploader = useUploadImage();


    const router = useRouter();
    const [user] = useAtom(userAtomAsync);

    const { data } = useQuery(["seller", props.params.id], () => Server.seller(props.params.id), {
        suspense: true,
        onError: (error) => {
            router.replace("/seller_requests");
        },
        retry: 0

    });



    const bag = data?.bags[0];


    const [sellerInfo, setSellerInfo] = useState<ISeller>({
        id: props.params.id,
        ...data!.seller
    });

    const [bagInfo, setBagInfo] = useState<IBag>({
        ...(bag as any)
    });

    const [latlng, setLatlng] = useState({
        lat: bag?.latitude ?? 0,
        lng: bag?.longitude ?? 0,
    })


    async function update() {

        const updates = {
            ...sellerInfo,
            active: true,
            latitude: latlng.lat,
            longitude: latlng.lng,
            bagCategory: sellerInfo.storeType,
            bagName: bagInfo.name,
            bagPrice: bagInfo.price,
            bagDescription: bagInfo.description ?? "",
            bagOriginalPrice: bagInfo.originalPrice,
            bagPhoto: bagInfo.photo ?? "https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3",
            bagTags: (bagInfo.tags ?? "") as any,
            bagID: bagInfo.id,
            storeType: sellerInfo.storeType,
        } as IAcceptSeller

        const validation = AcceptSeller.safeParse(updates);

        if (validation.success) {
            await Server.updateSeller(props.params.id, updates);
            router.push("/sellers");
        }
    }

    async function remove() {
        await Server.removeSeller(props.params.id);
        router.push("/sellers");
    }




    return <div className="w-full max-w-3xl mx-auto -mt-4">
        <h2 className="font-bold text-black text-2xl  w-full max-w-3xl ">Assing Seller to Bag</h2>

        <div className=" bg-white shadow-md  flex  flex-col items-start  sm:flex-row px-2   my-6">


            <div className="p-2 flex-1 pb-24 sm:border-r-2 border-dashed border-stone-500 space-y-2">
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
                    <label className="text-sm font-bold px-2">Seller Location <sub>(use google map)</sub></label>
                    <input
                        value={sellerInfo.address}
                        onChange={(e) => setSellerInfo({ ...sellerInfo, address: e.target.value })}
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
                        <input type="file"
                            onChange={async (e) => {
                                const file = e.target.files?.[0];
                                if (!file) return;
                                const url = await uploader(file, props.params.id, "seller/photo");
                                setSellerInfo(a => ({ ...a, photo: url }));
                            }}
                            className="absolute inset-0 opacity-0" />
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


                {!(sellerInfo.active) && <button onClick={remove} className="border-2 border-stone-600 text-black font-bold px-12 py-1.5 rounded-md my-4 w-full">
                    Delete
                </button>}

            </div>

            <div className="p-2 flex-1 space-y-2 sticky top-20">
                <h2 className="font-bold text-black text-2xl mx-auto sm:text-center">Bag</h2>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Name</label>
                    <input
                        value={bagInfo.name}
                        onChange={(e) => setBagInfo({ ...bagInfo, name: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 flex   rounded-lg focus-within:bg-stone-200">
                    <div className="flex-1">
                        <label className="text-sm font-bold px-2">Bag Price</label>
                        <input
                            value={bagInfo.price}
                            onChange={(e) => setBagInfo({ ...bagInfo, price: Number(e.target.value) })}
                            className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />

                    </div>
                    <div className="flex-1">
                        <label className="text-sm font-bold px-2">Bag Original Price</label>
                        <input
                            value={bagInfo.originalPrice}
                            onChange={(e) => setBagInfo({ ...bagInfo, originalPrice: Number(e.target.value) })}
                            className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                    </div>
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Descripion</label>
                    <textarea
                        rows={2}
                        value={bagInfo.description ?? ""}
                        onChange={(e) => setBagInfo({ ...bagInfo, description: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name"></textarea>
                </div>

                <div className="p-2 rounded-lg hover:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Photo</label>
                    <label className="relative overflow-hidden w-full flex items-center justify-center">
                        <input
                            onChange={async (e) => {
                                const file = e.target.files?.[0];
                                if (!file) return;
                                // todo this will make the old photos saved for ever!
                                const url = await uploader(file, (Math.random() * 100000000).toString(), `seller/${props.params.id}/photo`);
                                setBagInfo(a => ({ ...a, photo: url }));
                            }}
                            type="file" className="absolute inset-0 opacity-0" />

                        {bagInfo.photo ? <img src={bagInfo.photo} className="absolute object-cover inset-0 " /> : null}
                        <div className="ring-2 z-50 ring-black/50 aspect-square p-2 rounded-full">
                            <Lucide.Image size={20} className="text-black" />
                        </div>
                    </label>
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Tags</label>
                    <select
                        value={bagInfo.tags}
                        onChange={(e) => setBagInfo({ ...bagInfo, tags: e.target.value })}
                        className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name">
                        <option value="valA">valA</option>
                        <option value="valB">valB</option>
                        <option value="valC">valC</option>

                    </select>

                </div>

                <button
                    onClick={update}
                    className="bg-black text-white font-bold px-12 py-2 rounded-md my-4 w-full">
                    {sellerInfo.active ? "Update" : "Assign"}
                </button>

            </div>

        </div>


    </div>

}