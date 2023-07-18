"use client";

import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useEffect } from "react";
import * as Server from "@/local_repository/server";
import { ResponsiveContainer, Area, AreaChart, CartesianGrid, XAxis } from "recharts";


export default function Page() {
    console.log("need the user");
    const [user] = useAtom(userAtomAsync);

    useEffect(() => {
        Server.ping();
    }, []);

    return <div className="max-w-2xl w-full mx-auto">
        <div className="grid sm:grid-cols-3 gap-8 grid-cols-1 px-2">

            <Card title="Track" value="0" />
            <Card title="Requests" value="0" />
            <Card title="Issues" value="0" />
        </div>

        <div className="mt-12">

            <Chart data={[
                { x: "1", y: 0 },
                { x: "2", y: 1 },
                { x: "3", y: .4 },
                { x: "4", y: 10 },
                { x: "5", y: 8 },
                { x: "6", y: 1 },
            ]} />

        </div>
    </div>
}


function Card(props: {
    title: string,
    value: string,
}) {
    return <div className="text-white rounded-xl bg-black p-8 text-lg">
        <p className="font-mono font-bold text-5xl">{props.value}</p>
        <p className="font-mono font-bold text-white/80 text-2xl">{props.title}</p>
    </div>
}


type Props = {
    data: { x: string, y: number }[];
}
function Chart(props: Props) {
    return (
        <div style={{ width: '100%', height: 250 }}>
            <ResponsiveContainer>
                <AreaChart
                    data={props.data}
                    margin={{
                        left: 16,
                        right: 16,
                        top: 16,
                    }}
                >
                    <defs>
                        <linearGradient id="colorUv" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%" stopColor="#000" stopOpacity={0.8} />
                            <stop offset="95%" stopColor="#000" stopOpacity={0} />
                        </linearGradient>
                    </defs>

                    <XAxis tickSize={15} dataKey="x" interval={0} />
                    <CartesianGrid strokeDasharray="8 8" opacity={0.15} />
                    <Area
                        type="natural"
                        strokeWidth={2}
                        dataKey="y"
                        fill='url(#colorUv)'
                        stroke="#000"
                        fillOpacity={1}
                    />
                </AreaChart>
            </ResponsiveContainer>
        </div>
    );
}
