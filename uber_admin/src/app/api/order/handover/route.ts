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
  IOrder,
  ITrack,
  StartDeliveryOrder,
} from "@/utils/types";
import * as admin from "firebase-admin";
import { cancelOrderExpiration } from "../delivery/finish/route";

// i think only the seller is allowed to do this
export async function POST(request: Request) {
  const order = HandOverForAll.parse(await request.json());

  if (await BlocForNot("seller#" + order.sellerID, request))
    return VerificationError();

  if (order.isPickup == false) {
    // set track to be toSeller = true

    await firebase.firestore().collection("tracks").doc(order.id).update({
      toSeller: true,
      lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else {
    // set order to be delivered
    await firebase.firestore().collection("orders").doc(order.id).update({
      isDelivered: true,
      lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });

    await cancelOrderExpiration(order.id);

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

    // send notification to the client, so he can
    await notifyClient(order);
  }

  console.log(order);

  return new Response(JSON.stringify(order));
}

async function notifyClient(order: IOrder) {
  const query = await firebase
    .firestore()
    .collection("clients")
    .doc(order.clientID)
    .get();
  const data = query.data();

  if (!data) return new Response("Client not found");
  const clientToken = data.notiID;

  await firebase.messaging().send({
    token: clientToken,
    fcmOptions: {
      analyticsLabel: "orderAcceptedNotifyClient",
    },
    android: {
      priority: "high",
      ttl: 1000 * 60 * 10,
      notification: {
        body: `you help save ${order.bagName}`,
        title: "Thank you",
      },
    },
    data: {
      type: "self_pickup",
      order: JSON.stringify(order),
      // if we can sign a hash for this unique (also time based hashed) so no one can fake it
      orderID: order.id,
    },
  });
}
