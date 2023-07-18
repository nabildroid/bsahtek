import Profile from "@/components/profile"
import NavButton from "../../components/navButton"
import dynamic from "next/dynamic";

type Props = {
    children: React.ReactNode
}

const LayoutMiddleware = dynamic(() => import("./layoutMiddleware"), {
    ssr: false,
});

export default function Layout(props: Props) {

    return <div className="w-full min-h-screen bg-stone-100">
        <div className="px-2 sm:px-16 flex justify-between items-center py-2">
            <img src="/vercel.svg" alt="logo" className="h-6" />

            <div className="hidden sm:flex px-2  sm:px-3 w-full overflow-x-auto  md:justify-center items-center space-x-6">
                <NavButtons />
            </div>

            <Profile />
        </div>

        <div className="sm:hidden px-2 sm:px-3 w-full overflow-x-auto flex md:justify-center items-center space-x-6">
            <NavButtons />
        </div>

        <div className="mt-12">
            <LayoutMiddleware> {props.children}</LayoutMiddleware>
        </div>

    </div>

}


function NavButtons() {
    return <>
        <NavButton label="Home" link="/" />
        <NavButton
            label="Sellers"
            link="/sellers"
        />
        <NavButton
            label="Seller Requests"
            link="/seller_requests"
        />
        <NavButton
            label="Delivers"
            link="/delivers"
        />
        <NavButton
            label="Deliver Requests"
            link="/deliver_requests"
        />

        <NavButton
            label="Issues"
            link="/issues"
        />
    </>
}