"use client"

import Icons from "@/svgs";


type Props = {
    children: React.ReactNode;
}

export default function Layout(props: Props) {

    return <div className="max-w-6xl mx-auto">
        {props.children}

        <div className="grid grid-cols-1 px-2 sm:grid-cols-2 lg:grid-cols-4 gap-6  mt-8">

            {Array(20).fill(0).map((_, i) => <div className=" group shadow-md bg-white ring ring-stone-200 rounded-lg overflow-hidden">
                <div className="p-2">

                    <img src={`https://picsum.photos/seed/${i}/200/300`} className="object-cover w-full rounded-lg h-16" />

                    <div className="-mt-16">
                        <div className="flex items-center p-2">
                            <img src="https://picsum.photos/seed/picsum/200/300" className="w-10 h-10 rounded-full object-cover ring ring-white" />

                            <div className="flex-1" />

                        </div>
                    </div>
                    <div className="p-2">
                        {/* add price:56$, store name:.., location, phonenumber  */}
                        <h2 className="text-lg font-bold">Sepirate Zigadi Plus</h2>
                        <p className="text-sm text-gray-500">Suprize bag <b>56$</b> <span>+565669655655</span></p>
                    </div>

                </div>
                <button className="text-black font-bold group-hover:text-white  group-hover:bg-black py-2 w-full">
                    Edit
                </button>

            </div>
            )}
        </div>
        <div className="text-center mt-8">
            <button className="px-8 text-white py-2 bg-black rounded-md mx-auto ">
                Load more
            </button>
        </div>


    </div>
}