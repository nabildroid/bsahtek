import { Rubik } from 'next/font/google'

const rubik = Rubik({
    subsets: ["latin", "arabic"]
})


export const dynamic = "force-static"

export default function Layout(props: {
    children: React.ReactNode
}) {

    return <html lang="en" className={rubik.className + "  bg-[#003e4d]"}>
        <body className='' >
            {props.children}
        </body>
    </html>
}