import firebase, {
  AllowOnlyIF,
  VerificationError,
} from "@/app/api/repository/firebase";
import { Deliver, IDeliver } from "@/utils/types";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

type Context = {
  params: {
    deliverID: string;
  };
};
// get details of a deliver
export async function GET(request: Request, context: Context) {
  if (await AllowOnlyIF("admin", request)) return VerificationError();

  const { deliverID } = context.params;

  const query = await firebase
    .firestore()
    .collection("delivers")
    .doc(deliverID)
    .get();
  if (!query.exists) return new Response("Not Found", { status: 404 });

  const data = {
    id: query.id,
    ...query.data(),
  } as IDeliver;

  return NextResponse.json({ deliver: data });
}

// handle both acceptance, (there is not updates)
export async function POST(request: Request, context: Context) {
  if (await AllowOnlyIF(request)) return VerificationError();

  const { deliverID } = context.params;
  const demand = Deliver.parse(await request.json());
  if (demand.id != "" && deliverID !== demand.id)
    return new Response("Bad Request", { status: 400 });

  await firebase.auth().setCustomUserClaims(deliverID, {
    role: "deliver",
  });

  const sellerRef = firebase.firestore().collection("delivers").doc(deliverID);
  if (demand.active) {
    await sellerRef.update({
      active: true,
    });

    try {
      await firebase.auth().setCustomUserClaims(deliverID, {
        role: "deliver",
      });
    } catch (e) {
      console.log("how the delivery user doesn't exists?", deliverID);
    }
  } else {
    await sellerRef.update({
      suspended: true,
    });

    await firebase.auth().updateUser(deliverID, {
      disabled: true,
    });
  }
  return NextResponse.json({ success: true });
}
