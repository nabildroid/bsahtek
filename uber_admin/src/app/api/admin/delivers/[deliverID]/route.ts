import firebase, {
  NotAllowed,
  VerificationError,
} from "@/app/api/repository/firebase";
import { IDeliver } from "@/utils/types";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

type Context = {
  params: {
    deliverID: string;
  };
};
// get details of a deliver
export async function GET(request: Request, context: Context) {
  if (await NotAllowed(request)) return VerificationError();

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
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}

export async function DELETE(request: Request, context: Context) {
  if (await NotAllowed(request)) return VerificationError();

  const { deliverID } = context.params;
  await firebase.firestore().collection("delivers").doc(deliverID).delete();
  // todo see what to do with the information that is related to this deliver (orders ....)

  return NextResponse.json({ success: true });
}
