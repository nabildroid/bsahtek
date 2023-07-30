import firebase from "@/app/api/repository/firebase";
import { calculateDistance, calculateSquareCenter } from "@/utils/coordination";
import * as Schema from "@/db/schema";
import {
  AcceptOrder,
  IOrder,
  ITrack,
  StartDeliveryOrder,
  Track,
  Tracking,
} from "@/utils/types";
import * as admin from "firebase-admin";
import { z } from "zod";
import db from "../../repository/db";
import { eq, sql } from "drizzle-orm";

const Props = z.object({
  orderID: z.string(),
  rating: z.number().max(5).min(1).int(),
  clientID: z.string(),
});

export async function POST(request: Request) {
  const { orderID, rating, clientID } = Props.parse(await request.json());

  console.log({ orderID, rating, clientID });

  const order = await firebase
    .firestore()
    .collection("orders")
    .doc(orderID)
    .get();

  if (!order.exists) return new Response("No such order", { status: 404 });

  const data = order.data() as IOrder;

  if (data.clientID !== clientID)
    return new Response("You are not allowed to rate this order", {
      status: 403,
    });

  await db
    .update(Schema.bagsTable)
    .set({
      rating: sql`${Schema.bagsTable.rating} * .9  +  ${rating} * .1`,
    })
    .where(eq(Schema.bagsTable.id, Number(data.bagID)))
    .execute();
  return new Response("Rated successfully", { status: 200 });
}
