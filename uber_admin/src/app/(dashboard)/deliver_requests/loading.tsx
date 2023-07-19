export default function Loading() {

    return <div className="max-w-lg mx-auto space-y-8">
        {Array(4).fill(0).map((request, i) => <div className="p-2 py-3 items-center flex rounded-md bg-slate-300 h-20 animate-pulse">
        </div>)}
    </div>

}