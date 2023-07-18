export default function Page() {


    return <div className="max-w-3xl mx-auto  grid sm:grid-cols-3 grid-cols-1 px-2 gap-6">
        {Array(10).fill(0).map((_, i) => <div className="bg-white group ring ring-stone-200 shadow rounded-lg overflow-hidden">
            <div className="p-2 text-center ">
                <img className="w-20 mx-auto aspect-square rounded-full" src="https://avatars.githubusercontent.com/u/19208222?v=4" />
                <h2 className="font-bold my-2">Lakrib Nabil</h2>
                <p className="text-stone-800">Ain benian</p>
                <p className="text-black">+2565645656556</p>

            </div>

            <button className="text-black font-bold group-hover:text-white group-hover:bg-black py-2 w-full">
                Edit
            </button>

        </div>
        )}

    </div>
}