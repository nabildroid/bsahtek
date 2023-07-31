import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { calculateSquareCenter } from "@/utils/coordination";
import { AcceptOrder, ITrack, StartDeliveryOrder } from "@/utils/types";
import * as admin from "firebase-admin";

export async function POST(request: Request) {
  const order = StartDeliveryOrder.parse(await request.json());

  if (await BlocForNot("deliver#" + order.deliveryManID, request))
    return VerificationError();

  // send notification to client
  const query = await firebase
    .firestore()
    .collection("clients")
    .doc(order.clientID)
    .get();
  const data = query.data();

  const newTrack: ITrack = {
    id: order.id,
    clientID: order.clientID,
    clientLocation: order.clientAddress,
    sellerLocation: order.sellerAddress,
    deliverLocation: order.deliveryAddress,
    createdAt: new Date(),
    updatedAt: new Date(),
    orderID: order.id,
    toClient: false,
    toSeller: true,
    path: [],
    deliveryManID: order.deliveryManID,
    sellerID: order.sellerID,
  };

  await admin.firestore().collection("tracks").doc(order.id).set(newTrack);

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
        body: `${order.deliveryName} is on the way to deliver your ${order.bagName} to ${order.clientTown}`,
        title: "Your order is on the way",
      },
    },
    data: {
      type: "delivery_start",
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      order: JSON.stringify(order),
    },
  });

  console.log(order);

  return new Response(JSON.stringify(order));
}
