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

  if (distanceToClient > 0.1 && distanceToClient < 1) {
    update.toClient = true;

    await EndDelivery(tracking.clientID);

    // get client token
  }

  if (distanceToSeller > 0.1 && distanceToSeller < 1) {
    update.toSeller = true;
    console.log("notify Seller");
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
        type: "delivery_end",
      },
    });
  }
}
