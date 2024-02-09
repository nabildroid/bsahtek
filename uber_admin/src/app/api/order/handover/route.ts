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
  HandOverForAll,
  HandOverToClient,
  IOrder,
  ITrack,
  StartDeliveryOrder,
} from "@/utils/types";
import * as admin from "firebase-admin";
import { cancelOrderExpiration } from "../delivery/finish/route";
import { updateStats } from "../route";

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
    await firebase
      .firestore()
      .collection("orders")
      .doc(order.id)
      .update({
        isDelivered: true,
        lastUpdate: admin.firestore.FieldValue.serverTimestamp() as any,
      });

    await cancelOrderExpiration(order.id);

    // update the quantities
    const sellerZone = calculateSquareCenter(
      order.sellerAddress.longitude,
      order.sellerAddress.latitude,
      30
    );

    await firebase
      .firestore()
      .collection("zones")
      .doc(`${sellerZone.x},${sellerZone.y}`)
      .set(
        {
          quantities: {
            [order.bagID]: admin.firestore.FieldValue.increment(
              order.quantity * -1
            ),
          },
        },
        { merge: true }
      );

    ///
    await updateStats({
      selled: { increment: Number(order.bagPrice) },
    });
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
