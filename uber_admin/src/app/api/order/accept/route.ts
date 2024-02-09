import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { calculateSquareCenter } from "@/utils/coordination";
import { AcceptOrder, IOrder, IOrderExpireTask } from "@/utils/types";
import * as admin from "firebase-admin";
import * as Tasks from "@/app/api/repository/tasks";
import { NextRequest, NextResponse } from "next/server";

export async function POST(request: Request) {
  const order = AcceptOrder.parse(await request.json());

  if (await BlocForNot("seller#" + order.sellerID, request))
    return VerificationError();

  const sellerZone = calculateSquareCenter(
    order.sellerAddress.longitude,
    order.sellerAddress.latitude,
    30
  );

  // update the quantities
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

  // set up cronjob to reset the quantities after order expiration
 

  // update the order
  await firebase
    .firestore()
    .collection("orders")
    .doc(order.id)
    .update({
      lastUpdate: admin.firestore.FieldValue.serverTimestamp() as any,
      sellerAddress: order.sellerAddress,
      sellerName: order.sellerName,
      sellerPhone: order.sellerPhone,
    } satisfies Partial<IOrder>);

  // notify client
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
        body: `your order${order.quantity > 1 ? "s" : ""} ${
          order.bagName
        } has been accepted`,
        title: "Order Accepted",
      },
    },
    data: {
      type: "order_accepted",
      order: JSON.stringify(order),
    },
  });

  // notify sellers Topic;
  if (!order.isPickup) {
    const topic = `zone-${sellerZone.y}-${sellerZone.x}`;
    console.log(topic);
    await firebase.messaging().sendToTopic(
      topic,
      {
        notification: {
          tag: order.id,
          body: `${order.clientName} need a delivery to  for ${order.bagName}`,
          title: "Delivery to ${order.clientTown}",
        },

        data: {
          type: "orderAccepted",
          order: JSON.stringify(order),
        },
      },
      {
        contentAvailable: true,
        priority: "high",
      }
    );
  }

  return new Response(JSON.stringify(order));
}

