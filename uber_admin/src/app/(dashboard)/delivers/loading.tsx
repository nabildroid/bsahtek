export default function Loading() {
    return <div className="max-w-3xl mx-auto  grid sm:grid-cols-3 grid-cols-1 px-2 gap-6">
        {Array(6).fill(0).map((deliver, i) => <div className="bg-white aspect-square animate-pulse group ring ring-stone-200 shadow rounded-lg overflow-hidden">

        </div>)}
    </div>;

}