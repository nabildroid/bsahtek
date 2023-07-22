import firebase, {
  AllowOnlyIF,
  VerificationError,
} from "../../repository/firebase";
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  if (await AllowOnlyIF("admin", request)) return VerificationError();

  const query = await firebase
    .firestore()
    .collection("uber")
    .doc("stats")
    .get();

  if (!query.exists) return NextResponse.json({});

  const stats = query.data();

  return NextResponse.json({ stats });
}
