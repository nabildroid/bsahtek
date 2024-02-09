
import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { calculateDistance, calculateSquareCenter } from "@/utils/coordination";
import {
  ITrack,
  StartDeliveryOrder,
  Track,
  Tracking,
} from "@/utils/types";
import * as admin from "firebase-admin";
import { NextResponse } from "next/server";


// todo (Security) for sake of no-extra read we need to hach the orderID,acceptedDate,clientID,sellerID,deliverID

export async function POST(request: Request) {
  const tracking = Tracking.parse(await request.json());
  if (await BlocForNot("deliver#" + tracking.deliveryManID, request))
    return VerificationError();

  console.log(tracking);

  const update = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp() as any as Date,
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

  if (distanceToClient > 0.5 && distanceToClient < 1 && tracking.toSeller) {
    update.toClient = true;

    console.log("notify client");
    await EndDelivery(tracking.clientID);
  }

  // todo allowing the user to temp with toSeller is kinda bad!, but we are already accepting his GeoLocation, so it's not that bad
  if (distanceToSeller < 1 && !tracking.toSeller) {
    console.log("notify Seller");
    await InformSeller(tracking.sellerID, tracking.orderID);

    tracking.toSeller = true;
  }


  await firebase
    .firestore()
    .collection("tracks")
    .doc(tracking.id)
    .update(update);

  return NextResponse.json(tracking);
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

    // await firebase.messaging().send({
    //   token: clientToken,
    //   fcmOptions: {
    //     analyticsLabel: "OrderArrived",
    //   },
    //   android: {
    //     priority: "high",
    //     ttl: 1000 * 60 * 10,
    //     notification: {
    //       body: `your order is almost there`,
    //       title: "Ready to pick up",
    //     },
    //   },
    //   data: {
    //     click_action: "FLUTTER_NOTIFICATION_CLICK",
    //     type: "delivery_need_to_pickup",
    //     orderID,
    //   },
    // });
  }
}
