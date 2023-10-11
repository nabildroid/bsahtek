


export default function Page() {

    return <div>
        <div className="relative">

            <div className="inset-0 pb-20 absolute opacity-50 overflow-hidden">
                <svg
                    className="w-full h-full scale-[2.5] -translate-x-32 -translate-y-40 text-green-400"
                    xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>

            </div>
            <div className="inset-0 absolute backdrop-blur-3xl"></div>




            <div className="max-w-5xl min-h-screen flex flex-col mx-auto  text-white  px-2 relative">

                <div className="py-6 flex items-center justify-between">
                    <div className="flex items-center space-x-2">
                        <div></div>
                        <span className="text-sm font-bold">Bsahtek - بصحتك</span>
                    </div>

                    <nav className="hidden sm:block">
                        <ul className="flex items-center space-x-4">
                            <li><a className="inline-block px-2 pt-1 rounded-lg " href="#">About</a></li>
                            <li><a className="inline-block px-2 pt-1 rounded-lg " href="#">Our Mission</a></li>
                            <li><a className="inline-block px-2 pt-1 rounded-lg " href="#">Privacy</a></li>
                        </ul>
                    </nav>

                </div>

                <div className="flex-1 h-full flex-col sm:flex-row flex  items-start mt-8 ">

                    <div className="flex-1 h-full  sm:sticky top-12  flex flex-col justify-center items-start">
                        <h1 className="text-6xl font-medium ">
                            Bienvenue sur Bsahtek - Votre Allié <span className="text-teal-100">Contre le Gaspillage</span> Alimentaire

                        </h1>


                        <p className="mt-12">Promouvoir la Solidarité Alimentaire : Notre Engagement à Réduire le Gaspillage et à Nourrir les Plus Vulnérables</p>

                        <button className="w-full sm:w-auto mt-8 uppercase bg-emerald-600 px-3 py-1 rounded-full">
                            Telecharger
                        </button>

                    </div>

                    <div className="flex-1 w-full shrink-0 relative mt-8 sm:mt-0">
                        <div className="sm:h-screen w-full sm:-translate-x-16 sm:-translate-y-2  ">
                            <img src="/static/screenshots.png" />

                        </div>

                    </div>

                </div>


            </div>




        </div>
        <div className="flex flex-col justify-center  space-y-16 h-screen  max-w-5xl  mx-auto  text-white  px-2 text-center">
            <h2 className="uppercase text-emerald-200">about us</h2>
            <p className=" leading-normal font-medium text-2xl">Lorem ipsum, dolor sit amet consectetur adipisicing elit. Ipsam repellendus iure, eveniet est vel maxime deleniti alias quia, cum eius qui explicabo veritatis rerum corrupti labore, numquam tempora illo similique!</p>

        </div>
    </div>

}