/**
 * if the pickup is true update the Order to be Delivered and send noti to client to close the delivery
 * else update the Track to be toSeller = true
 */

import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { calculateSquareCenter } from "@/utils/coordination";
import {
  AcceptOrder,
  HandOverForAll,
  HandOverToClient,
  ITrack,
  StartDeliveryOrder,
} from "@/utils/types";
import * as admin from "firebase-admin";

// i think only the seller is allowed to do this
export async function POST(request: Request) {
  if (await BlocForNot("seller", request)) return VerificationError();

  const order = HandOverForAll.parse(await request.json());

  if (order.isPickup == false) {
    // set track to be toSeller = true

    await firebase.firestore().collection("tracks").doc(order.id).update({
      toSeller: true,
      lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else {
    await firebase.firestore().collection("orders").doc(order.id).update({
      isDelivered: true,
      lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });

    const today = new Date().toLocaleDateString();
    const statsRef = firebase.firestore().collection("uber").doc("stats");

    await statsRef.set(
      {
        [`today.${today}.orders`]: admin.firestore.FieldValue.increment(1),
        [`today.${today}.selled`]: admin.firestore.FieldValue.increment(
          Number(order.bagPrice)
        ),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // set order to be delivered
  }

  console.log(order);

  return new Response(JSON.stringify(order));
}
