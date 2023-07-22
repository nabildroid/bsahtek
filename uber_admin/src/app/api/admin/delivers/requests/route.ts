import firebase, {
  AllowOnlyIF,
  VerificationError,
} from "@/app/api/repository/firebase";
import { IDeliver } from "@/utils/types";
import { NextResponse } from "next/server";

// get list of all  (pending-tobe) drivers
export async function GET(request: Request) {
  if (await AllowOnlyIF("admin", request)) return VerificationError();

  const query = await firebase
    .firestore()
    .collection("delivers")
    .where("active", "==", false)
    .get();

  const requests = query.docs.map((doc) => {
    return {
      id: doc.id,
      ...doc.data(),
    } as IDeliver;
  });

  return NextResponse.json({ requests });
}
