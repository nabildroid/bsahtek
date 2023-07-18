import * as Lucide from "lucide-react";
import Link from "next/link";



export default function Page() {

    return <div className="max-w-lg mx-auto space-y-8">
        {Array(10).fill(0).map((_, i) => <div key={i} className="p-2 py-3 items-center flex rounded-md bg-white">
            <div className="aspect-square w-16 flex justify-center items-center">
                <Lucide.Car size={40} className="text-stone-900" />
            </div>

            <div className="flex-1">
                <h1 className="font-bold text-sm text-black">Sotre name of the sotre</h1>
                <p className="text-stone-800">Algeria, ain benian +2135565254</p>
                <p className="text-xs mt-1">
                    <span className="inline-block p-0.5 bg-stone-500/30 border border-stone-600/40">food</span>
                </p>
            </div>

            <div className="space-x-1 text-sm">
                <Link href="/seller_requests/ezfzefzefz/assign" className="px-2 py-1 rounded-md bg-black text-white">
                    Accept
                </Link>
                <button className="px-2 py-1 rounded-md border bg-stone-500/30 border-stone-600/40  text-black">
                    Delete
                </button>
            </div>

        </div>)}
    </div>
}