import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { IClient } from "@/utils/types";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const query = await firebase
    .firestore()
    .collection("clients")
    .where("active", "==", false)
    .get();

  const requests = query.docs
    .map((doc) => {
      return {
        id: doc.id,
        ...doc.data(),
      } as IClient;
    })
    .filter((a: any) => !a.suspended);

  return NextResponse.json({ requests });
}

export const dynamic = "force-dynamic";
