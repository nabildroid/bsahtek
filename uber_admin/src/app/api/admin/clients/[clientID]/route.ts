import { addOrder } from "@/app/api/order/route";
import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { Client, Deliver, IClient, IOrder } from "@/utils/types";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

type Context = {
  params: {
    clientID: string;
  };
};
// get details of a deliver
export async function GET(request: Request, context: Context) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const { clientID } = context.params;

  const query = await firebase
    .firestore()
    .collection("clients")
    .doc(clientID)
    .get();
  if (!query.exists) return new Response("Not Found", { status: 404 });

  const data = {
    id: query.id,
    ...query.data(),
  } as IClient;

  return NextResponse.json({ client: data });
}

// handle both acceptance, (there is not updates)
export async function POST(request: Request, context: Context) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const { clientID: clientID } = context.params;
  const demand = Client.parse(await request.json());
  if (demand.id != "" && clientID !== demand.id)
    return new Response("Bad Request", { status: 400 });

  const clientRef = firebase.firestore().collection("clients").doc(clientID);

  if (demand.active) {
    try {
      await firebase.auth().updateUser(clientID, {
        phoneNumber: "+213" + demand.phone.replaceAll(" ", ""),
      });

      await firebase.auth().setCustomUserClaims(clientID, {
        role: "client",
      });
    } catch (e) {
      console.log("how the client user doesn't exists?", clientID);
      return new Response("Something bad did happen:(", { status: 400 });;
    }

    await clientRef.update({
      active: true,
    });

    try {
      const order = await addOrder(demand.requestedOrder);

      await notifyClient(clientID, order);
    } catch (e) {
      console.error("order didn't go through");
    }
  } else {
    await clientRef.update({
      suspended: true,
      acrive: false,
    });

    await firebase.auth().updateUser(clientID, {
      disabled: true,
    });
  }
  return NextResponse.json({ success: true });
}

async function notifyClient(clientID: string, order: IOrder) {
  const query = await firebase
    .firestore()
    .collection("clients")
    .doc(clientID)
    .get();
  if (!query.exists) return;

  const data = query.data();

  const notiID = data!.notiID;

  await firebase.messaging().send({
    token: notiID,
    fcmOptions: {
      analyticsLabel: "clientActivation",
    },
    android: {
      priority: "high",
      ttl: 1000 * 60 * 10,
      notification: {
        imageUrl: order.bagImage,
        body: `${order.clientName} you requested  ${
          order.quantity == 1 ? "one" : order.quantity
        } ${order.bagName}`,
        title: `${order.clientName}, Account accepted!`,
      },
    },

    data: {
      order: JSON.stringify(order),
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      type: "account_activated",
    },
  });
}
