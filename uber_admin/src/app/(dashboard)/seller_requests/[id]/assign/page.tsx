"use client";
import * as Lucide from "lucide-react";

type Props = {
    params: {
        id: string
    }
}

export default function Page(props: Props) {

    return <div className="w-full max-w-3xl mx-auto -mt-4">
        <h2 className="font-bold text-black text-2xl  w-full max-w-3xl ">Assing Seller to Bag</h2>

        <div className=" bg-white shadow-md  grid grid-cols-1 sm:grid-cols-2 px-2   mt-6">


            <div className="p-2 sm:border-r-2 border-dashed border-stone-500 space-y-2">
                <h2 className="font-bold  text-black text-2xl mx-auto sm:text-center">Seller</h2>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Name</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Store Name</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Phone</label>
                    <input disabled className="w-full  px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Location</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg hover:bg-stone-200">
                    <label className="text-sm font-bold px-2">Seller Photo</label>
                    <label className="relative w-full flex items-center justify-center">
                        <input type="file" className="absolute inset-0 opacity-0" />
                        <div className="ring-2 ring-black/50 aspect-square p-2 rounded-full">
                            <Lucide.Image size={20} className="text-black" />

                        </div>
                    </label>
                </div>
            </div>

            <div className="p-2 space-y-2">
                <h2 className="font-bold text-black text-2xl mx-auto sm:text-center">Bag</h2>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Name</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Price</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Original Price</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

                <div className="p-2 rounded-lg hover:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Photo</label>
                    <label className="relative w-full flex items-center justify-center">
                        <input type="file" className="absolute inset-0 opacity-0" />
                        <div className="ring-2 ring-black/50 aspect-square p-2 rounded-full">
                            <Lucide.Image size={20} className="text-black" />

                        </div>
                    </label>
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Bag Tags</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Seller Name" />
                </div>

            </div>



        </div>

        <button className="bg-black text-white font-bold px-12 py-2 rounded-md my-4 w-full">
            Assign
        </button>
    </div>

}