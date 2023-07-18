
import dynamic from "next/dynamic";

const LoginButton = dynamic(() => import("./components/loginButton"), {
    ssr: false,
    loading: () => <div className="mt-12 animate-pulse w-full bg-black text-black font-medium py-2 rounded-sm">
        loading...
    </div>
});


export default function Page() {

    return <div className="w-full px-4 h-screen bg-slate-50 flex items-center justify-center">

        <div className="text-center max-w-sm w-full">
            {/* logo */}
            <img src="/vercel.svg" alt="logo" className="mx-auto " />


            <LoginButton />
        </div>

    </div>

}