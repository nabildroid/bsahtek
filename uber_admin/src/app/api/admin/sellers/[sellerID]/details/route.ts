import db from "@/app/api/repository/db";

import * as admin from "firebase-admin";

import { eq } from "drizzle-orm";
import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { AcceptSeller, IOrder, ISeller, Seller } from "@/utils/types";
import { NextResponse } from "next/server";
import * as Schema from "@/db/schema";
import { IBag } from "@/types";
import { calculateSquareCenter } from "@/utils/coordination";
import { AdminBlocForNot } from "@/app/api/repository/admin_firebase";

export const dynamic = "force-dynamic";

type Context = {
  params: {
    sellerID: string;
  };
};
// get details of a seller
export async function GET(request: Request, context: Context) {
  if (await AdminBlocForNot(["seller_viewer", "analytic"], request))
    return VerificationError();
  const { sellerID } = context.params;

  const query = await firebase
    .firestore()
    .collection("sellers")
    .doc(sellerID)
    .get();
  if (!query.exists) return new Response("Not Found", { status: 404 });

  const seller = {
    id: query.id,
    ...query.data(),
  } as ISeller;

  //   get all orders of this seller
  const ordersquery = await firebase
    .firestore()
    .collection("orders")
    .where("sellerID", "==", sellerID)
    .get();

  const orders = ordersquery.docs.map((doc) => {
    return {
      id: doc.id,
      ...doc.data(),
      lastUpdate: doc.data().lastUpdate?.toDate().toISOString(),
      createdAt: doc.data().createdAt.toDate().toISOString(),
      acceptedAt: doc.data().acceptedAt?.toDate().toISOString(),
    } as IOrder;
  });

  return NextResponse.json({ seller, orders });
}
