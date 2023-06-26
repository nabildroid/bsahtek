import { NextApiRequest } from "next";
import { NextResponse } from "next/server";
import db from "../../repository/db";
import * as Schema from "@/db/schema";
import { between } from "drizzle-orm";
import {
  reverseCalculateSquareCenter,
  addKilometersToLongitude,
} from "@/utils/coordination";

export const dynamic = "force-dynamic";

export async function GET(
  req: Request,
  context: {
    params: { xy: string };
  }
) {
  const distance = 1;

  const [x, y] = context.params.xy.split(",").map(parseFloat);

  const { x: originalX, y: originalY } = reverseCalculateSquareCenter(
    x,
    y,
    distance
  );

  const boundryX = [
    addKilometersToLongitude(originalX, -distance),
    addKilometersToLongitude(originalX, distance),
  ];
  const boundryY = [
    addKilometersToLongitude(originalY, -distance),
    addKilometersToLongitude(originalY, distance),
  ];

  const rows = await db
    .select()
    .from(Schema.foodTable)
    .where(between(Schema.foodTable.longitude, boundryX[0], boundryX[1]))
    .execute();

  return NextResponse.json({
    x,
    originalX,
    params: boundryX,
    data: rows,
  });
}
