import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { Deliver, IDeliver, IOrder, ITrack } from "@/utils/types";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

type Context = {
  params: {
    deliverID: string;
  };
};
// get details of a deliver
export async function GET(request: Request, context: Context) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const { deliverID } = context.params;

  const query = await firebase
    .firestore()
    .collection("delivers")
    .doc(deliverID)
    .get();
  if (!query.exists) return new Response("Not Found", { status: 404 });

  const deliver = {
    id: query.id,
    ...query.data(),
  } as IDeliver;

  //   get all orders of this seller
  const ordersquery = await firebase
    .firestore()
    .collection("orders")
    .where("deliveryManID", "==", deliverID)
    .get();

  const orders = ordersquery.docs.map((doc) => {
    console.log(doc.id)
    return {
      id: doc.id,
      ...doc.data(),
      lastUpdate: doc.data().lastUpdate?.toDate().toISOString(),
      createdAt: doc.data().createdAt.toDate().toISOString(),
    } as IOrder;
  });




  return NextResponse.json({ deliver, orders });
}
