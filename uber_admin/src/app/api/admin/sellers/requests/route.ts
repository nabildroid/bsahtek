import firebase, {
  NotAllowed,
  VerificationError,
} from "@/app/api/repository/firebase";
import { ISellerRequest } from "@/utils/types";
import { NextResponse } from "next/server";

// get list of all  (pending-tobe) drivers
export async function GET(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  const query = await firebase
    .firestore()
    .collection("seller_requests")
    .where("active", "==", "false")
    .get();

  const requests = query.docs.map((doc) => {
    return {
      id: doc.id,
      ...doc.data(),
    } as ISellerRequest;
  });

  return NextResponse.json({ requests });
}
