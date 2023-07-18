import firebase from "@/app/api/repository/firebase";
import { calculateDistance, calculateSquareCenter } from "@/utils/coordination";
import {
  AcceptOrder,
  ITrack,
  StartDeliveryOrder,
  Track,
  Tracking,
} from "@/utils/types";
import * as admin from "firebase-admin";

export async function POST(request: Request) {
  const tracking = Tracking.parse(await request.json());

  const update = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp() as any as Date,
    delivertManID: tracking.deliveryManID, // todo check if belongs to him!
    deliveryLocation: tracking.deliverLocation,
    path: admin.firestore.FieldValue.arrayUnion(
      tracking.deliverLocation
    ) as any,
  } as Partial<ITrack>;

  const distanceToClient = calculateDistance(
    tracking.deliverLocation,
    tracking.clientLocation
  );
  const distanceToSeller = calculateDistance(
    tracking.deliverLocation,
    tracking.sellerLocation
  );

  console.log({ distanceToClient, distanceToSeller });

  if (distanceToClient > -1 && distanceToClient < 1 && false) {
    update.toClient = true;

    console.log("notify client");
    await EndDelivery(tracking.clientID);
  }

  if ((distanceToSeller > -1 && distanceToSeller < 1) || true) {
    console.log("notify Seller");
    await InformSeller(tracking.sellerID, tracking.orderID);
  }

  await firebase
    .firestore()
    .collection("tracks")
    .doc(tracking.id)
    .update(update);

  return new Response(JSON.stringify({}));
}

async function EndDelivery(clientID: string) {
  const query = await firebase
    .firestore()
    .collection("clients")
    .doc(clientID)
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
