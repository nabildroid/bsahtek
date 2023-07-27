import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { calculateSquareCenter } from "@/utils/coordination";
import { AcceptOrder, IOrder } from "@/utils/types";
import * as admin from "firebase-admin";

export async function POST(request: Request) {
  if (await BlocForNot("seller", request)) return VerificationError();

  const order = AcceptOrder.parse(await request.json());

  await admin
    .firestore()
    .collection("orders")
    .doc(order.id)
    .update({
      acceptedAt: order.acceptedAt,
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

  // if (!data) return new Response("Client not found");
  // const clientToken = data.notiID;

  // await firebase.messaging().send({
  //   token: clientToken,
  //   fcmOptions: {
  //     analyticsLabel: "orderAcceptedNotifyClient",
  //   },
  //   android: {
  //     priority: "high",
  //     ttl: 1000 * 60 * 10,
  //     notification: {
  //       body: `your order${order.quantity > 1 ? "s" : ""} ${
  //         order.bagName
  //       } has been accepted`,
  //       title: "Order Accepted",
  //     },
  //   },
  //   data: {
  //     type: "order_accepted",
  //     order: JSON.stringify(order),
  //   },
  // });

  // notify sellers Topic;
  if (!order.isPickup) {
    const center = calculateSquareCenter(
      order.clientAddress.longitude,
      order.clientAddress.latitude,
      30
    );
    const topic = `zone-${center.y}-${center.x}`;
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
