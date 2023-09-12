import firebase, {
  BlocForNot,
  VerificationError,
} from "../../repository/firebase";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  if (await BlocForNot("admin", request)) return VerificationError();

  const query = await firebase.firestore().collection("orders").get();

  const orders = query.docs.map((d) => ({
    ...d.data(),
    id: d.id,
  }));

  return NextResponse.json({ orders });
}
