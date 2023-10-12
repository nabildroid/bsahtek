import { Rubik } from 'next/font/google'
import type { Metadata } from 'next'

export const metadata: Metadata = {
    title: 'Bsahtek - بصحتك',
    description: 'Bsahtek est une application mobile qui met en relation ses utilisateurs avec des boulangeries, pâtisseries, supermarchés, fleuristes, etc. afin de leur proposer des produits invendus à prix réduits sous la forme de paniers à sauver.',
    applicationName: "Bsahtek - بصحتك",
    keywords: "food, algeria",
    icons: "/static/logo.png",
}

const rubik = Rubik({
    subsets: ["latin", "arabic"]
})





export const dynamic = "force-static"

export default function Layout(props: {
    children: React.ReactNode
}) {

    return <html lang="en" className={rubik.className + "  bg-[#003e4d] scroll-smooth"}>
        <body className='' >
            {props.children}
        </body>
    </html>
}