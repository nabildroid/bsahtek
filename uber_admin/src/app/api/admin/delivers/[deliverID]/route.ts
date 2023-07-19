import firebase, {
  NotAllowed,
  VerificationError,
} from "@/app/api/repository/firebase";
import { IDeliver } from "@/utils/types";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

// get details of a deliver
export async function GET(
  request: Request,
  context: {
    params: {
      deliverID: string;
    };
  }
) {
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

// accept deliver and assign them a bag
export async function POST(request: Request) {
  return NextResponse.json({ success: true });
}

// update deliver informations
export async function PATCH(request: Request) {
  return NextResponse.json({ success: true });
}
