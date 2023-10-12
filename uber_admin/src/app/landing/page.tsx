import Image from "next/image";


export default function Page() {

    return <div>
        <div className="relative">

            <div className="inset-0 pb-20 absolute opacity-50 overflow-hidden">
                <svg
                    className="w-full h-full scale-[2.5] -translate-x-32 -translate-y-40 text-green-400"
                    xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>

            </div>
            <div className="inset-0 absolute backdrop-blur-3xl"></div>




            <div className="max-w-6xl min-h-screen flex flex-col mx-auto  text-white  px-2 relative">

                <div className="py-6 flex items-center justify-between">
                    <div className="flex items-center space-x-2">
                        <div></div>
                        <span className="text-sm font-bold">Bsahtek - بصحتك</span>
                    </div>

                    <nav className="hidden sm:block">
                        <ul className="flex items-center space-x-4">
                            <li><a className="inline-block px-2 pt-1 rounded-lg " href="#about">À Propos de Nous</a></li>
                            <li><a className="inline-block px-2 pt-1 rounded-lg " href="#vision">Notre Vision</a></li>
                            <li><a className="inline-block px-2 pt-1 rounded-lg " href="#what">Ce Que Nous Faisons</a></li>
                            <li><a className="inline-block px-2 pt-1 rounded-lg " href="#how">Comment Ça Marche</a></li>
                        </ul>
                    </nav>

                </div>

                <div className="flex-1 h-full flex-col sm:flex-row flex  items-start mt-8 ">

                    <div className="flex-1 h-full  sm:sticky top-12  flex flex-col justify-center items-start">
                        <h1 className="text-6xl font-medium ">
                            Bienvenue sur Bsahtek - Votre Allié <span className="text-teal-100">Contre le Gaspillage</span> Alimentaire

                        </h1>


                        <p className="mt-12 max-w-lg">Promouvoir la Solidarité Alimentaire : Notre Engagement à Réduire le Gaspillage et à Nourrir les Plus Vulnérables</p>

                        <a target="_blank" href="https://play.google.com/store/apps/details?id=me.laknabil.uber_client" className="max-w-xs  mx-auto sm:mx-0 text-left flex items-center space-x-3 border-2 border-white/60 sm:w-auto mt-8 px-3  rounded-lg py-1">
                            <img className="w-6 h-6" src="/static/playstore.png" />
                            <div>
                                <h3 className="uppercase leading-none text-xs">Get It ON </h3>
                                <p className="font-bold leading-none text-lg font-serif">Google Play</p>
                            </div>

                        </a>

                    </div>

                    <div className="flex-1 w-full shrink-0 relative mt-8 sm:mt-0">
                        <div className="sm:min-h-screen w-full sm:-translate-x-8 sm:-translate-y-2  ">
                            <Image priority alt="screenshot" width={720} height={600} src="/static/screenshots.png" />

                        </div>

                    </div>

                </div>


            </div>













        </div>
        <div id="about" className="sticky top-0 flex flex-col justify-center bg-[#003e4d]  space-y-16 h-screen  max-w-5xl  mx-auto  text-white  px-2 text-center">
            <h2 className="uppercase text-emerald-200">À Propos de Nous</h2>
            <p className=" leading-normal font-medium text-2xl text-left">
                Chez Bsahtek, nous croyons en un avenir où chaque repas compte.
                Nous sommes déterminés à réduire le gaspillage alimentaire en mettant à profit la technologie moderne pour connecter les acteurs clés
                de l'industrie alimentaire avec ceux qui en ont besoin. <br></br><br></br>

                Notre mission est simple mais puissante : éliminer le gaspillage alimentaire tout en nourrissant ceux qui ont faim.
            </p>

        </div>

        <div id="vision" className="sticky top-0 flex flex-col justify-center bg-[#003e4d] border-t-2 border-white/10  space-y-16 h-screen  max-w-5xl  mx-auto  text-white  px-2 text-center">
            <h2 className="uppercase text-emerald-200">Notre Vision</h2>
            <p className=" leading-normal font-medium text-2xl text-left">
                Nous rêvons d'un monde où chaque aliment est valorisé, où chaque surplus alimentaire trouve son chemin vers quelqu'un qui l'appréciera.
                À travers notre application mobile, nous espérons catalyser un changement durable dans la façon dont nous gérons nos ressources alimentaires.
            </p>

        </div>





        <div id="what" className="sticky top-0 flex flex-col justify-center bg-[#003e4d] border-t-2 border-white/10  space-y-16 h-screen  max-w-5xl  mx-auto  text-white  px-2 text-center">
            <h2 className="uppercase text-emerald-200">Ce Que Nous Faisons</h2>
            <p className=" leading-normal font-medium text-2xl text-left">
                Notre application Bsahtek est votre outil pour réduire le gaspillage alimentaire.
                Elle permet aux restaurants, supermarchés, épiceries, boulangeries, et producteurs locaux de partager leurs excédents alimentaires avec ceux qui en ont besoin.
                D'un simple geste, vous pouvez contribuer à prévenir la perte de nourriture tout en faisant une différence dans la vie de ceux qui ont du mal à se nourrir.
            </p>

        </div>


        <div id="how" className="sticky top-0 flex flex-col justify-center bg-[#003e4d] border-t-2 border-white/10  space-y-16 h-screen  max-w-5xl  mx-auto  text-white  px-2 text-center">
            <h2 className="uppercase text-emerald-200">Comment Ça Marche</h2>
            <p className=" leading-normal font-medium text-2xl text-left">
                Partagez Vos Surplus : Les entreprises alimentaires enregistrent leurs excédents alimentaires sur notre application.

                <br></br>
                <br></br>
                Trouvez des Aliments : Les utilisateurs recherchent les aliments disponibles à proximité.
                <br></br>
                <br></br>
                Récupérez et Dégustez : Les bénéficiaires récupèrent la nourriture, la consomment, et contribuent à réduire le gaspillage alimentaire.

            </p>

        </div>


        <div className="sticky top-0 flex flex-col justify-center bg-[#003e4d] border-t-2 border-white/10  space-y-16 h-screen  max-w-5xl  mx-auto  text-white  px-2 text-center">
            <h2 className="uppercase text-emerald-200">Notre Impact</h2>
            <p className=" leading-normal font-medium text-2xl text-left">
                Grâce à la collaboration de notre communauté, nous avons déjà empêché des tonnes d'aliments de finir à la poubelle.
                Chaque repas partagé est une victoire pour notre planète et une aide précieuse pour nos concitoyens dans le besoin.


            </p>

        </div>





    </div>

}