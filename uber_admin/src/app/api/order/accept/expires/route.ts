import { OrderExpireTask } from "@/utils/types";
import * as admin from "firebase-admin";
import * as Tasks from "@/app/api/repository/tasks";
import { NextResponse } from "next/server";
import { cancelOrderExpiration } from "../../delivery/finish/route";

// todo implement upstash request signature verification
export async function POST(request: Request) {
  const message = OrderExpireTask.parse(await request.json());
  await cancelOrderExpiration(message.orderID);

  await admin
    .firestore()
    .collection("zones")
    .doc(message.zone)
    .update({
      ["quantities." + message.bagID]: admin.firestore.FieldValue.increment(
        message.quantity
      ),
    });

  // todo you can send notifications to the seller, or deliver guy, or the client
  return NextResponse.json({ done: true });
}
