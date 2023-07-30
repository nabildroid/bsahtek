import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { calculateDistance, calculateSquareCenter } from "@/utils/coordination";
import {
  AcceptOrder,
  IOrder,
  ITrack,
  StartDeliveryOrder,
  Track,
  Tracking,
} from "@/utils/types";

import * as Tasks from "@/app/api/repository/tasks";

import * as admin from "firebase-admin";

export async function POST(request: Request) {
  if (await BlocForNot("deliver", request)) return VerificationError();

  const tracking = Tracking.parse(await request.json());

  const updateTrack = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp() as any as Date,
    deliveryLocation: tracking.deliverLocation,
    path: admin.firestore.FieldValue.arrayUnion(
      tracking.deliverLocation
    ) as any,
  } as Partial<ITrack>;

  const updateOrder = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp() as any as Date,
    isDelivered: true,
  } as Partial<IOrder>;

  // todo notify the seller

  // store the updates in one transaction to avoid inconsistency
  firebase
    .firestore()
    .collection("tracks")
    .doc(tracking.id)
    .update(updateTrack);
  firebase
    .firestore()
    .collection("orders")
    .doc(tracking.orderID)
    .update(updateOrder);

  await notifyClientEndDelivery(tracking.clientID, tracking.orderID);

  await cancelOrderExpiration(tracking.orderID);

  const today = new Date().toLocaleDateString();
  const statsRef = firebase.firestore().collection("uber").doc("stats");

  await statsRef.update({
    [`today.${today}.orders`]: admin.firestore.FieldValue.increment(1),
    [`today.${today}.delivered`]: admin.firestore.FieldValue.increment(1),
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    // todo what about updating the price also
  });

  return new Response(JSON.stringify({}));
}

async function notifyClientEndDelivery(clientID: string, orderID: string) {
  const query = await firebase
    .firestore()
    .collection("clients")
    .doc(clientID)
    .get();

  const data = query.data();

  if (data) {
    const clientToken = data.notiID;

    await firebase.messaging().send({
      token: clientToken,
      fcmOptions: {
        analyticsLabel: "OrderArrived",
      },
      android: {
        priority: "high",
        ttl: 1000 * 60 * 10,
        notification: {
          body: `your order is almost there`,
          title: "Ready to pick up",
        },
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        orderID: orderID,
        type: "delivery_end",
      },
    });
  }
}

async function InformSeller(sellerID: string, orderID: string) {
  const query = await firebase
    .firestore()
    .collection("sellers")
    .doc(sellerID)
    .get();

  const data = query.data();

  console.log({ data });
  if (data) {
    const clientToken = data.notiID;

    await firebase.messaging().send({
      token: clientToken,
      fcmOptions: {
        analyticsLabel: "OrderArrived",
      },
      android: {
        priority: "high",
        ttl: 1000 * 60 * 10,
        notification: {
          body: `your order is almost there`,
          title: "Ready to pick up",
        },
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        type: "delivery_need_to_pickup",
        orderID,
      },
    });
  }
}

export async function cancelOrderExpiration(orderID: string) {
  const ids = await Tasks.getIdsByURLpartial(orderID);

  await Promise.all(ids.map((id) => Tasks.remove(id)));
}
