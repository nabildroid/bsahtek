"use client"

import { userAtomAsync } from "@/state";
import Icons from "@/svgs";
import { useAtom } from "jotai";
import { useRouter } from "next/navigation";
import { useQuery } from "react-query";
import * as Server from "@/local_repository/server";
import { ago, diffInMin } from "@/utils";

type Props = {
  params: {
    id: string
  }
}


export default function Page(props: Props) {

  const router = useRouter();
  const [user] = useAtom(userAtomAsync);

  const { data: details } = useQuery(["seller", "details", props.params.id], () => Server.sellerDetails(props.params.id), {
    suspense: true,
    onError: (error) => {
      router.replace("/seller_requests");
    },
    retry: 0,
    
  });


  details?.orders.sort((a, b) => {
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
  })

  const orders = {
    thisMonths: details!.orders.filter((order) => {
      return new Date(order.createdAt).getMonth() === new Date().getMonth()
    }),
    lastMonths: details!.orders.filter((order) => {
      let prevMonth = new Date().getMonth() - 1;
      prevMonth = prevMonth > 0 ? prevMonth : 11;
      return new Date(order.createdAt).getMonth() === prevMonth
    })
  }
  console.log(orders);

  const sells = {
    thisMonths: orders.thisMonths.reduce((acc, order) => {
      if (!order.isDelivered) return acc;
      return acc + Number(order.bagPrice);
    }, 0),
    lastMonths: orders.lastMonths.reduce((acc, order) => {
      if (!order.isDelivered) return acc;
      return acc + Number(order.bagPrice);
    }, 0)
  }

  const ordersCount = {
    thisMonths: orders.thisMonths.reduce((acc, order) => {
      if (!order.isDelivered) return acc;
      return acc + 1;
    }, 0),
    lastMonths: orders.lastMonths.reduce((acc, order) => {
      if (!order.isDelivered) return acc;
      return acc + 1;
    }, 0)
  }

  const expiredCount = {
    thisMonths: orders.thisMonths.reduce((acc, order) => {
      if (order.isDelivered) return acc
      // check the last update with now, if it is more than 3 hours, then it is not delivered
      const lastUpdate = new Date(order.lastUpdate).getTime();
      const now = new Date().getTime();
      const diff = now - lastUpdate;
      if (diff < 1000 * 60 * 60 * 3) return acc;

      return acc + 1;
    }, 0),
    lastMonths: orders.lastMonths.reduce((acc, order) => {
      if (order.isDelivered) return acc;
      const lastUpdate = new Date(order.lastUpdate).getTime();
      const now = new Date().getTime();
      const diff = now - lastUpdate;
      if (diff < 1000 * 60 * 60 * 3) return acc;
      return acc + 1;
    }, 0)


  }



  return <div>

    < div className="mb-8 mt-4 pt-4 border-b border-stone-200 bg-stone-100/30 z-50  backdrop-blur-md sticky top-0" >

      <div className="flex items-start flex-wrap sm:space-x-2 text-xl text-stone-950 font-black pb-4 max-w-6xl mx-auto px-2 sm:px-0">
        <div className="leading-tight">
          <h1>{details!.seller.name}</h1>
          <p className="text-sm">{details!.seller.phone}</p>
        </div>
        <p className="font-mono">#{details!.seller.id?.slice(0, 10)}</p>


        <div className="flex-1" />
        <p>{details!.seller.storeAddress} - <span className="text-emerald-700">{details!.seller.storeName}</span> </p>
      </div>
    </div >


    <div className="max-w-6xl mx-auto px-2 sm:px-0">




      <h2 className="text-stone-800 font-medium mb-4">Stats this month and previous month</h2>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">

        <div className="flex  items-start p-8 rounded-md border-slate-300 border space-x-8">
          <div className="aspect-square p-2 rounded-full bg-emerald-100 ">
            <Icons.Package className="w-8  h-8 text-emerald-700" />
          </div>
          <div >
            <div className="text-xl font-bold text-stone-700"><span className="text-stone-800">{ordersCount.thisMonths}</span> order</div>
            <div className="text-xl font-bold text-stone-400"><span className="text-stone-500">{ordersCount.lastMonths}</span> last month</div>
          </div>
        </div>

        <div className="flex  items-start p-8 rounded-md border-slate-300 border space-x-8">
          <div className="aspect-square p-2 rounded-full bg-emerald-100 ">
            <Icons.Dollar className="w-8  h-8 text-emerald-700" />
          </div>
          <div >
            <div className="text-xl font-bold text-stone-700"><span className="text-stone-800">{sells.thisMonths}dz</span> sells</div>
            <div className="text-xl font-bold text-stone-400"><span className="text-stone-500">{sells.lastMonths}dz</span> last month</div>
          </div>
        </div>

        <div className="flex  items-start p-8 rounded-md border-slate-300 border space-x-8">
          <div className="aspect-square p-2 rounded-full bg-emerald-100 ">
            <Icons.X className="w-8  h-8 text-emerald-700" />
          </div>
          <div >
            <div className="text-xl font-bold text-stone-700"><span className="text-stone-800">{expiredCount.thisMonths}</span> expired order</div>
            <div className="text-xl font-bold text-stone-400"><span className="text-stone-500">{expiredCount.lastMonths}</span> last month</div>
          </div>
        </div>

      </div>

      <h2 className="text-stone-800 font-medium mb-4">All Orders</h2>
      <div className="relative overflow-x-auto border border-stone-300  sm:rounded-lg ">
        <table className="w-full text-sm text-left text-stone-500 ">
          <thead className="text-xs text-stone-700 uppercase bg-stone-200/50 ">
            <tr>
              <th scope="col" className="px-3 py-3">
                ID
              </th>
              <th scope="col" className="px-3 py-3">
                Date
              </th>
              <th scope="col" className="px-3 py-3 hidden sm:table-cell">
                Bag
              </th>
              <th scope="col" className="px-3 py-3">
                Client
              </th>
              <th scope="col" className="px-3 py-3 hidden sm:table-cell">
                Delivery
              </th>

              <th scope="col" className="px-3 py-3 hidden sm:table-cell">
                Duration
              </th>

              <th scope="col" className="px-3 py-3 hidden sm:table-cell">
                Total
              </th>
            </tr>
          </thead>
          <tbody>

            {
              details!.orders.map(order => <tr key={order.id} className="bg-white border-b ">
                <th scope="row" className="px-3 py-4 font-mono">
                  #{order.id.slice(0, 10)}
                </th>
                <td className="px-3 py-4 font-mono">
                  {new Date(order.createdAt).toLocaleString()}
                </td>
                <td className="px-3 py-4 hidden sm:table-cell">
                  {order.bagName}
                </td>
                <td className="px-3 py-4 font-medium text-stone-900 whitespace-nowrap ">
                  {order.clientName}
                </td>
                <td className="px-3 py-4 hidden sm:table-cell">
                  {order.deliveryName ?? order.isPickup ? 'pickup' : 'delivery'}
                </td>
                <td className="px-3 py-4 hidden sm:table-cell">
                  {diffInMin(new Date(order.createdAt), new Date(order.lastUpdate))} min
                </td>
                <td className="px-3 py-4 hidden sm:table-cell">
                  {order.bagPrice}dz
                </td>

              </tr>)

            }
          </tbody>
        </table>
      </div>
    </div>
  </div >;

}




