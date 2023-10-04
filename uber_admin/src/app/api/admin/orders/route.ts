import { AdminBlocForNot } from "../../repository/admin_firebase";
import firebase, {
  BlocForNot,
  VerificationError,
} from "../../repository/firebase";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  if (
    await AdminBlocForNot(
      ["analytic", "clients_viewer", "seller_viewer"],
      request
    )
  )
    return VerificationError();

  const query = await firebase.firestore().collection("orders").get();

  const orders = query.docs.map((d) => {
    const data = d.data();
    return {
      ...data,
      createdAt: data.createdAt.toDate(),
      id: d.id,
    };
  });

  return NextResponse.json({ orders });
}
