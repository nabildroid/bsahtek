"use client";
import * as Lucide from "lucide-react";

type Props = {
    params: {
        id: string
    }
}

export default function Page(props: Props) {

    return <div className="w-full max-w-3xl mx-auto -mt-4">
        <h2 className="font-bold text-black text-2xl  w-full max-w-3xl ">Deliver Profile</h2>

        <div className=" bg-white shadow-md  grid grid-cols-1 px-2   mt-6 py-2">

            <div className="p-2 border-b-2 border-dashed border-stone-500 space-y-2">
                <h2 className="font-bold  text-black text-2xl mx-auto sm:text-center">Deliver Informations</h2>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Name</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Store Name</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Phone</label>
                    <input disabled className="w-full  px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg focus-within:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Location</label>
                    <input className="w-full px-2 border-b-2 bg-transparent border-black/50 outline-none" placeholder="Deliver Name" />
                </div>

                <div className="p-2 rounded-lg hover:bg-stone-200">
                    <label className="text-sm font-bold px-2">Deliver Photo</label>
                    <label className="relative w-full flex items-center justify-center">
                        <input type="file" className="absolute inset-0 opacity-0" />
                        <div className="ring-2 ring-black/50 aspect-square p-2 rounded-full">
                            <Lucide.Image size={20} className="text-black" />

                        </div>
                    </label>
                </div>
            </div>


        </div>

        <button className="bg-black text-white font-bold px-12 py-2 rounded-md my-4 w-full">
            Assign
        </button>
    </div>

}