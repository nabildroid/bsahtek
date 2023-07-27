import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { ISeller } from "@/utils/types";
import { NextResponse } from "next/server";

// get list of all  (pending-tobe) drivers
export async function GET(request: Request) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const query = await firebase
    .firestore()
    .collection("sellers")
    .where("active", "==", false)
    .get();

  const requests = query.docs.map((doc) => {
    return {
      id: doc.id,
      ...doc.data(),
    } as ISeller;
  });

  return NextResponse.json({ requests });
}
