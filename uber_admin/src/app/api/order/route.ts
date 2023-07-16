import { IOrder, NewOrder, Order } from "@/utils/types";
import * as admin from "firebase-admin";
import firebase from "../repository/firebase";
import { TypeOf, z } from "zod";

export async function POST(request: Request) {
  const newOrder = NewOrder.parse(await request.json());
  console.log(newOrder);
  const query = await firebase
    .firestore()
    .collection("sellers")
    .doc(newOrder.sellerID)
    .get();
  const data = query.data();

  if (!data) return new Response("Seller not found");
  const sellerToken = data.notiID;

  const { id } = await firebase
    .firestore()
    .collection("orders")
    .add({
      ...newOrder,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  const order = {
    id,
    ...newOrder,
  } satisfies IOrder;

  await firebase.messaging().send({
    token: sellerToken,
    fcmOptions: {
      analyticsLabel: "newOrder",
    },
    android: {
      priority: "high",
      ttl: 1000 * 60 * 10,
      notification: {
        imageUrl: order.bagImage,
        body: `${order.clientName} requested a ${
          order.quantity == 1 ? "one" : order.quantity
        } ${order.bagName}`,
        title: `new Request from ${order.clientName}`,
      },
    },

    data: {
      order: JSON.stringify(order),
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
  });

  return new Response(JSON.stringify(order));
}
