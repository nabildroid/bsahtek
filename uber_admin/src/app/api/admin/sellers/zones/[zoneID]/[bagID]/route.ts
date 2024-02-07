import db from "@/app/api/repository/db";

import * as admin from "firebase-admin";

import { eq } from "drizzle-orm";
import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { AcceptSeller, ISeller, NewSeller, Seller } from "@/utils/types";
import { NextResponse } from "next/server";
import * as Schema from "@/db/schema";
import { IBag } from "@/types";
import { calculateSquareCenter } from "@/utils/coordination";
import { revalidateTag } from "next/cache";
import { AdminBlocForNot } from "@/app/api/repository/admin_firebase";

export const dynamic = "force-dynamic";

// accept seller a

type Context = {
  params: {
    zoneID: string;
    bagID: number;
  };
};

export async function POST(request: Request, context: Context) {
  if (await AdminBlocForNot(["seller_accept"], request))
    return VerificationError();

  const { quantity } = await request.json();

  const zone = firebase
    .firestore()
    .collection("zones")
    .doc(context.params.zoneID);

  // update the quantities
  await zone.set(
    {
      quantities: {
        [context.params.bagID]: Number(quantity ?? 0),
      },
    },
    { merge: true }
  );

  return NextResponse.json({ success: true });
}
