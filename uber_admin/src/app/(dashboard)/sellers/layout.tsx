"use client"

import Icons from "@/svgs";
import Link from "next/link";


type Props = {
    children: React.ReactNode;
}

export default function Layout(props: Props) {

    return <div className="max-w-6xl mx-auto">
        <div className="grid grid-cols-1 px-2 sm:grid-cols-2 lg:grid-cols-4 gap-6  mt-8">

            {Array(20).fill(0).map((_, i) => <div className=" shadow-md bg-slate-200 rounded-lg ring-2 ring-white overflow-hidden">
                <img src={`https://picsum.photos/seed/${i}/200/300`} className="object-cover w-full rounded-lg aspect-video" />

                <div className="-mt-16">
                    <div className="flex items-center p-2">
                        <img src="https://picsum.photos/seed/picsum/200/300" className="w-10 h-10 rounded-full object-cover ring ring-white" />

                        <div className="flex-1" />

                        <button className="rounded-full hover:bg-slate-300 aspect-square bg-stone-200 p-2 text-black">
                            <Icons.Tool className="w-5 h-4 " />
                        </button>
                        <button className="rounded-full hover:bg-slate-300 aspect-square ml-2 bg-stone-200 p-2 text-black">
                            <Icons.Search className="w-5 h-4 " />
                        </button>
                    </div>
                </div>
                <div className="p-2">
                    {/* add price:56$, store name:.., location, phonenumber  */}
                    <h2 className="text-lg font-bold">Sepirate Zigadi Plus</h2>
                    <p className="text-sm text-gray-500">Suprize bag <b>56$</b> <span>+565669655655</span></p>
                </div>

            </div>
            )}




        </div>
        <div className="text-center mt-8">
            <button className="px-8 text-white py-2 bg-black rounded-md mx-auto ">
                Load more
            </button>
        </div>


        {props.children}
    </div>
}