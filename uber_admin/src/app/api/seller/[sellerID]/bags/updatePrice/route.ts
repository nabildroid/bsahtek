import db from "@/app/api/repository/db";
import { and, between, eq } from "drizzle-orm";
import * as Schema from "@/db/schema";
import { NextResponse } from "next/server";
import { BlocForNot, VerificationError } from "@/app/api/repository/firebase";

export const POST = async (
  request: Request,
  { params }: { params: { sellerID: string } }
) => {
  if (await BlocForNot(`seller#${params.sellerID}`, request))
    return VerificationError();

  const data = (await request.json()) as {
    price: number;
  };

  const rows = await db
    .update(Schema.bagsTable)
    .set({
      price: data.price,
    })
    .where(eq(Schema.bagsTable.sellerID, params.sellerID))
    .execute();

  console.log(rows);

  return NextResponse.json({ bags: rows });
};
