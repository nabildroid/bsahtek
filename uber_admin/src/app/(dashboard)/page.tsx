"use client";

import { userAtomAsync } from "@/state";
import { useAtom } from "jotai";
import { useEffect, useState } from "react";
import * as Server from "@/local_repository/server";
import { ResponsiveContainer, Area, AreaChart, CartesianGrid, XAxis } from "recharts";
import { cn } from "@/lib/utils";
import { useQuery } from "react-query";
import { IStats } from "@/types";
import { ValueOf } from "next/dist/shared/lib/constants";



function fillMounthHistory(data: { orders: number, date: Date }[]) {

    for (let i = 0; i < 30; i++) {
        const date = new Date();
        date.setDate(date.getDate() - i);

        const index = data.findIndex((a: any) => {
            const date2 = new Date(a.date);
            return date2.getDate() === date.getDate();
        });

        if (index === -1) {
            data.push({
                orders: 0,
                date: date,
            });
        }
    }

    return data.sort((a, b) => {
        const date1 = new Date(a.date);
        const date2 = new Date(b.date);

        return date1.getDate() - date2.getDate();
    });

    return data;
}



type Entry = ValueOf<IStats["today"]>;
export default function Page() {
    console.log("need the user");
    const [user] = useAtom(userAtomAsync);



    const [isRealtime, setIsRealtime] = useState(false);

    const { data } = useQuery(["stats"], Server.stats, {
        refetchInterval: isRealtime ? 1000 * 10 : false,
        suspense: true,
    });


    const todayKey = new Date().toLocaleDateString();
    const today = ((data as any)?.today[todayKey] as unknown ?? null) as Entry | null;




    return <>
        <div className="max-w-2xl w-full mx-auto">

            <div className="flex items-center justify-between mx-1">
                <select className="outline-none ring-black  ring-2 px-4 bg-transparent py-1 rounded-md text-black font-bold text-sm">
                    <option value="day">Today</option>
                    {/* <option value="month">This Month</option>
                    <option value="year">This Year</option> */}
                </select>

                <button className={cn(
                    "outline-none ring-black duration-300 ease-in-out ml-1 ring-2 px-4 bg-transparent py-1 rounded-md text-black font-bold text-sm"
                    , isRealtime && "no-underline  text-white bg-black hover:line-through hover:bg-transparent hover:text-black"
                    , !isRealtime && "line-through hover:no-underline text-black hover:bg-black hover:text-white"
                )} onClick={() => setIsRealtime(a => !a)}>
                    Near Realtime
                </button>

            </div>

            <div className="grid sm:grid-cols-3 gap-8 grid-cols-1 px-2 sm:px-0 mt-2">

                <Card title="Earning" value={today?.selled?.toString() ?? "0"} />
                <Card title="Orders" value={today?.orders?.toString() ?? "0"} />
                <Card title="Delivers Request" value={today?.deliversRequests?.toString() ?? "0"} />
            </div>

        </div>
        <div className="mt-12 py-3 bg-white shadow-md border-t-2 border-stone-200">
            <div className=" max-w-2xl w-full mx-auto">
                <h2 className="text-black font-bold text-sm mb-2">Orders in this mounth</h2>

                <Chart data={
                    fillMounthHistory(
                        Object.entries((data?.today) ?? {}).map(([key, value]) => ({
                            orders: value.orders,
                            date: new Date(key),
                        }))
                    ).map((x, i) => ({
                        x: x.date.getDate().toString(),
                        y: x.orders,
                    }))
                } />

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
