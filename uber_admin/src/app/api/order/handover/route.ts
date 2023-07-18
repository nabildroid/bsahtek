/**
 * if the pickup is true update the Order to be Delivered and send noti to client to close the delivery
 * else update the Track to be toSeller = true
 */

import firebase from "@/app/api/repository/firebase";
import { calculateSquareCenter } from "@/utils/coordination";
import {
  AcceptOrder,
  HandOver,
  ITrack,
  StartDeliveryOrder,
} from "@/utils/types";
import * as admin from "firebase-admin";

export async function POST(request: Request) {
  const order = HandOver.parse(await request.json());

  if (order.isPickup == false) {
    // set track to be toSeller = true

    await firebase.firestore().collection("tracks").doc(order.id).update({
      toSeller: true,
      lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else {
    await firebase.firestore().collection("orders").doc(order.id).update({
      isDelivered: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // set order to be delivered
  }

  console.log(order);

  return new Response(JSON.stringify(order));
}
