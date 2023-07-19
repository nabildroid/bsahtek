import db from "@/app/api/repository/db";
import { eq } from "drizzle-orm";
import firebase, {
  NotAllowed,
  VerificationError,
} from "@/app/api/repository/firebase";
import { ISeller } from "@/utils/types";
import { NextResponse } from "next/server";
import * as Schema from "@/db/schema";

export const dynamic = "force-dynamic";

// get details of a seller
export async function GET(
  request: Request,
  context: {
    params: {
      sellerID: string;
    };
  }
) {
  if (await NotAllowed(request)) return VerificationError();
  const { sellerID } = context.params;

  const query = await firebase
    .firestore()
    .collection("sellers")
    .doc(sellerID)
    .get();
  if (!query.exists) return new Response("Not Found", { status: 404 });

  const data = {
    id: query.id,
    ...query.data(),
  } as ISeller;

  let bags = [] as any[];
  if (data.active) {
    const bags = await db
      .select()
      .from(Schema.bagsTable)
      .where(eq(Schema.bagsTable.sellerID, sellerID))
      .execute();

    if (bags.length == 0) {
      console.error(
        "how did you manage to accept a seller without assigning them a bag?"
      );
    }
  }

  return NextResponse.json({ seller: data, bags });
}

// accept seller and assign them a bag
export async function POST(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}

// update seller informations
export async function PATCH(request: Request) {
  if (await NotAllowed(request)) return VerificationError();

  return NextResponse.json({ success: true });
}
