import { NextResponse } from "next/server";
import firebase, {
  BlocForNot,
  VerificationError,
} from "../../../repository/firebase";
import * as Schema from "@/db/schema";
import { AdminBlocForNot } from "../../../repository/admin_firebase";

export const dynamic = "force-dynamic";

// get accepted sellers + todo: filters, search ...
export async function GET(request: Request) {
  if (await AdminBlocForNot(["seller_viewer"], request))
    return VerificationError();

  const zonesQuery = await firebase.firestore().collection("zones").get();

  const zones = zonesQuery.docs.map((zone) => ({
    id: zone.id,
    ...zone.data(),
  }));

  return NextResponse.json({ zones });
}
