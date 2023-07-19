import firebase, {
  NotAllowed,
  VerificationError,
} from "@/app/api/repository/firebase";
import { IDeliver } from "@/utils/types";
import { NextResponse } from "next/server";

// get list of all  (pending-tobe) drivers
export async function GET(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  const query = await firebase
    .firestore()
    .collection("delivers")
    .where("active", "==", true)
    .get();

  const delivers = query.docs.map((doc) => {
    return {
      id: doc.id,
      ...doc.data(),
    } as IDeliver;
  });

  return NextResponse.json({ delivers });
}
