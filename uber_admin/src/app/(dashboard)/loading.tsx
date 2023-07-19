
export default function Loading() {
    return <>
        <div className="max-w-2xl w-full mx-auto">

            <div className="flex items-center justify-between mx-1">
                <div className="text-transparent animate-pulse outline-none ring-black  ring-2 px-4 bg-transparent py-1 rounded-md text-black font-bold text-sm">
                    loading
                </div>



                <button className={"animate-pulse outline-none text-transparent ring-black duration-300 ease-in-out ml-1 ring-2 px-4 bg-transparent py-1 rounded-md text-black font-bold text-sm"} >
                    Near Realtime
                </button>
            </div>


            <div className="grid sm:grid-cols-3 gap-8 grid-cols-1 px-2 sm:px-0 mt-2">

                <div className="animate-pulse bg-slate-300 rounded-md h-32"></div>
                <div className="animate-pulse bg-slate-300 rounded-md h-32"></div>
                <div className="animate-pulse bg-slate-300 rounded-md h-32"></div>
            </div>

        </div>
        <div className="mt-12 py-3 bg-white shadow-md">
            <div className=" max-w-2xl w-full mx-auto">
                <h2 className="text-black font-bold text-sm mb-2">Orders in this mounth</h2>

                <div className="animate-pulse">
                    <div className="h-40 w-full bg-slate-300 rounded-md"></div>

                </div>
            </div>
        </div>
    </>
}