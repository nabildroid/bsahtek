import { INewOrder, IOrder, ISeller, NewOrder, Order } from "@/utils/types";
import * as admin from "firebase-admin";
import firebase, {
  BlocForNot,
  VerificationError,
} from "../repository/firebase";
import { TypeOf, z } from "zod";
import { seller } from "@/local_repository/server";
import { IStats } from "@/types";
import { ValueOf } from "next/dist/shared/lib/constants";

/**
 * 
 the order expering is issue because, we have a monorepo, but no-sharing between the apps/website

so, we need to hard code stuff, mostly durations for a thing to be considred as expired

same goes with FCM notification the TTL is critical!!


** Client post Order**
	->Acceptance +10 min (Canceled)
	->self-pickup  +1h (Canceled)
	->Start Delivering  +10min (Canceled)
	->Delivering in progress +1h (Canceled) 

for now, we don't need to enforced serverSide, only clientSide, since all parties will agree on these durations!
 */

export async function POST(request: Request) {
  if (await BlocForNot("", request)) return VerificationError();

  const newOrder = NewOrder.parse(await request.json());

  const order = await addOrder(newOrder);
  return new Response(JSON.stringify(order));
}

export async function addOrder(newOrder: INewOrder) {
  const query = await firebase
    .firestore()
    .collection("sellers")
    .doc(newOrder.sellerID)
    .get();
  const seller = {
    ...query.data(),
    id: query.id,
  } as ISeller;
  console.log(newOrder);

  if (!seller) throw Error("Seller not found");
  const sellerToken = (seller as any).notiID;

  console.log("whent through");

  const { id } = await firebase
    .firestore()
    .collection("orders")
    .add({
      ...newOrder,
      // you must not put the name, or phone of the seller, that happens only when the seller accept the order!
      lastUpdate: admin.firestore.FieldValue.serverTimestamp() as any,
    } as IOrder);

  const order = {
    id,
    ...newOrder,
  } as IOrder;

  console.log(order);

  try {
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
  } catch (e) {
    console.log("seller doesn't exists");
  }

  await updateStats({
    orders: "increment",
  });

  return order;
}
export async function updateStats(
  stats: Partial<{
    [k in keyof ValueOf<IStats["today"]>]:
      | number
      | "increment"
      | { increment: number };
  }>
) {
  const today = new Date().toLocaleDateString();
  const statsRef = firebase.firestore().collection("uber").doc("stats");

  const realState = Object.entries(stats).reduce((acc, [key, value]) => {
    if (value === "increment") {
      acc[key] = admin.firestore.FieldValue.increment(1) as any;
    } else if (typeof value === "object") {
      acc[key] = admin.firestore.FieldValue.increment(value.increment) as any;
    } else {
      acc[key] = value;
    }

    return acc;
  }, {} as any);

  const data = {
    today: {
      [today]: {
        ...realState,
      },
    },

    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  };

  await statsRef.set(data, { merge: true });
}
