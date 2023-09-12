"use client";

import { realTimeAtom, userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useEffect, useState } from "react";
import * as Server from "@/local_repository/server";
import { ResponsiveContainer, Area, AreaChart, CartesianGrid, XAxis, Tooltip } from "recharts";
import { cn, convertDatesToMonthStats } from "@/lib/utils";
import { useQuery } from "react-query";
import { IStats } from "@/types";
import { ValueOf } from "next/dist/shared/lib/constants";



function fillMounthHistory(data: { orders: number, date: Date }[]) {

    const dates = [] as Date[];

    data.forEach(d => dates.push(...Array(d.orders).fill("").map(() => d.date)));

    return convertDatesToMonthStats(dates);
}



type Entry = ValueOf<IStats["today"]>;
export default function Page() {
    console.log("need the user");
    const [user] = useAtom(userAtomAsync);
    const [isRealtime] = useAtom(realTimeAtom);


    const { data } = useQuery(["stats"], Server.stats, {
        refetchInterval: isRealtime ? 1000 * 10 : false,
        suspense: true,
    });


    const todayKey = new Date().toLocaleDateString();
    const today = ((data as any)?.today[todayKey] as unknown ?? null) as Entry | null;



    return <>
        <div className="max-w-2xl w-full mx-auto">


            <div className="grid sm:grid-cols-3 gap-8 grid-cols-1 px-2 sm:px-0 mt-2">

                <Card title="Earning" value={today?.selled?.toString() ?? "0"} />
                <Card title="Orders" value={today?.orders?.toString() ?? "0"} />
                <Card title="Client Request" value={today?.newClients?.toString() ?? "0"} />
            </div>

        </div>
        <div className="mt-12 py-3 bg-white shadow-md border-t-2 border-stone-200">
            <div className=" max-w-2xl w-full mx-auto">
                <h2 className="text-black font-bold text-sm mb-2 px-2">Orders in this mounth</h2>

                <Chart data={
                    fillMounthHistory(
                        Object.entries((data?.today) ?? {}).map(([key, value]) => ({
                            orders: value.orders,
                            date: new Date(key),
                        }))
                    )}
                />

            </div>
        </div>
    </>
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
                    data={props.data.map(d => ({
                        ...d,
                        orders: d.y,
                    }))}
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

                    <Tooltip


                        contentStyle={{
                            backgroundColor: "#1f2937", color: "#fff",
                            accentColor: "#ddd",
                        }} />
                    <CartesianGrid strokeDasharray="8 8" />


                    <XAxis dataKey="x"
                        interval={3}
                        tickSize={2}
                        fontSize={12}
                        rotate={12}
                    />
                    <CartesianGrid strokeDasharray="8 8" opacity={0.15} />
                    <Area
                        type="natural"
                        strokeWidth={2}
                        dataKey="orders"
                        fill='url(#colorUv)'
                        stroke="#000"
                        fillOpacity={1}
                    />
                </AreaChart>
            </ResponsiveContainer>
        </div>
    );
}
