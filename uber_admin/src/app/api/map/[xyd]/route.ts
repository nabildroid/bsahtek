import { NextApiRequest } from "next";
import { NextResponse } from "next/server";
import db from "../../repository/db";
import * as Schema from "@/db/schema";
import { and, between } from "drizzle-orm";
import {
  reverseCalculateSquareCenter,
  addKilometersToLongitude,
} from "@/utils/coordination";

export const dynamic = "force-dynamic";

export async function GET(
  req: Request,
  context: {
    params: { xyd: string };
  }
) {
  const [x, y, distance] = context.params.xyd.split(",").map(parseFloat);

  const { x: originalX, y: originalY } = reverseCalculateSquareCenter(
    x,
    y,
    distance
  );

  const boundryX = [
    addKilometersToLongitude(originalX, -distance / 2),
    addKilometersToLongitude(originalX, distance / 2),
  ];
  const boundryY = [
    addKilometersToLongitude(originalY, -distance / 2),
    addKilometersToLongitude(originalY, distance / 2),
  ];

  const rows = await db
    .select()
    .from(Schema.bagsTable)
    .where(
      and(
        between(Schema.bagsTable.longitude, boundryX[0], boundryX[1]),
        between(Schema.bagsTable.latitude, boundryY[0], boundryY[1])
      )
    )
    .execute();

  console.log(originalX, originalY, rows.length);
  return NextResponse.json({
    x,
    originalX,
    params: boundryX,
    foods: rows, //todo rename it to product!
  });
}
