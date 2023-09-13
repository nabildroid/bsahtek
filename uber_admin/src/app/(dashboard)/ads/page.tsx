"use client"
import useUploadImage from "@/hooks/useUploadImage";
import { Ad, IAd } from "@/utils/types";
import { useState } from "react";

import * as Server from "@/local_repository/server";
import { useQuery } from "react-query";

export default function Page() {
    const { refetch } = useQuery(["ads"], Server.getAds, {
        onSuccess(data) {
            setAds(data)
        },
    })

    const [ads, setAds] = useState<IAd[]>([]);

    async function removeAdd(props: {
        id?: string,
        index: number
    }) {

        if (props.id) {
            await Server.deleteAd(props.id);
            refetch();
        } else {
            setAds(ads => [...ads.filter((a, i) => i !== props.index)])
        }

    }


    async function saveAd(ad: IAd) {
        const { success } = Ad.safeParse(ad);
        if (!success) return;

        await Server.saveAd(ad);
        refetch();
    }

    return <div className="px-2 max-w-2xl mx-auto w-full">
        <h2 className="text-xl font-black text-stone-900">Advertisement</h2>
        <div className="grid grid-cols-2 gap-4 mt-4">

            {ads.map((ad, i) => <AD
                key={ad.id ?? i}
                delete={(id) => removeAdd({ id, index: i })}
                save={saveAd}
                {...ad}
            />)}

            <div className="bg-white text-black flex items-center justify-center border-2 border-dashed border-stone-600 rounded-md overflow-hidden shadow-md">
                <button
                    onClick={() => setAds(a => [...a, {
                        active: true,
                        location: "home",
                        name: "",
                        photo: "https://etre.pro/logo.png",
                    }])}
                >Add new</button>

            </div>


        </div>
    </div>
}

function AD(props: IAd & { save: (val: IAd) => void, delete: (id?: string) => void }) {
    const uploader = useUploadImage();
    const [isEdited, setIsEdited] = useState(false)

    const [val, setVal] = useState({ ...props });


    const update: typeof setVal = (v) => {
        setIsEdited(true);
        setVal(v);
    }

    return <div className="relative bg-white ring-2 ring-stone-300 rounded-md overflow-hidden shadow-md">

        {isEdited && <button
            onClick={() => props.save(val)}
            className="z-20 hover:bg-black absolute top-1 right-1 px-2 py-0.5 text-white bg-stone-900">
            save
        </button>}

        <div className="relative w-full aspect-video">
            <input
                onChange={async (e) => {
                    const file = e.target.files?.[0];
                    if (!file) return;
                    const url = await uploader(file, val.id ?? Date.now().toString(), "ads");
                    update({ ...val, photo: url })
                }}
                type="file" className="absolute inset-0 opacity-0" />
            <img className="z-10 w-full aspect-video" src={val.photo} />
        </div>

        <div className="p-2 space-y-2">
            <input value={val.name}
                onChange={e => update({ ...val, name: e.target.value })}
                placeholder="Extenral Link" type="text" className="p-2 w-full outline-none focus:ring-2 ring-black rounded-md bg-stone-100 text-black" />
            <select
                onChange={e => update({ ...val, location: e.target.value as any })}
                value={val.location} className="p-2 w-full outline-none focus:ring-2 ring-black rounded-md bg-stone-100 text-black">
                {Object.values(Ad.shape.location.Values).map(v =>
                    <option value={v} key={v}>{v}</option>
                )}
            </select>
        </div>

        <button
            onClick={() => props.delete(val.id)}
            className="w-full py-1 bg-black text-white">Delete</button>

    </div>;
}
