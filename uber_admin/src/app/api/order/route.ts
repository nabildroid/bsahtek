import { IOrder, NewOrder, Order } from "@/utils/types";
import * as admin from "firebase-admin";
import firebase, {
  BlocForNot,
  VerificationError,
} from "../repository/firebase";
import { TypeOf, z } from "zod";
import { seller } from "@/local_repository/server";

export async function POST(request: Request) {
  if (await BlocForNot("", request)) return VerificationError();

  const newOrder = NewOrder.parse(await request.json());
  const query = await firebase
    .firestore()
    .collection("sellers")
    .doc(newOrder.sellerID)
    .get();
  const data = query.data();
  console.log(newOrder);

  if (!data) return new Response("Seller not found");
  const sellerToken = data.notiID;

  console.log("whent through");

  const { id } = await firebase
    .firestore()
    .collection("orders")
    .add({
      ...newOrder,
      lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });

  const order = {
    id,
    ...newOrder,
  } as IOrder;

  console.log(order);

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
      type: "new_order",
    },
  });

  return new Response(JSON.stringify(order));
}
