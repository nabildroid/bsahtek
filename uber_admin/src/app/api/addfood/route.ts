import { NextResponse } from "next/server";
import * as Schema from "@/db/schema";
import db from "../repository/db";
import { firestore } from "../repository/firebase";
import { NewFood } from "@/utils/types";
import {
  calculateSquareCenter,
  reverseCalculateSquareCenter,
} from "@/utils/coordination";

export async function POST(request: Request) {
  const res = NewFood.parse(await request.json());

  const { insertId } = await db
    .insert(Schema.bagsTable)
    .values({
      category: res.category,
      county: res.county,
      description: res.description,
      isPromoted: res.isPromoted,
      latitude: res.latitude,
      longitude: res.longitude,
      name: res.name,
      photo: res.photo,
      rating: 0,
      sellerAddress: res.sellerAddress,
      sellerID: res.sellerID,
      sellerName: res.sellerName,
      sellerPhoto: res.sellerPhoto,
      tags: res.tags,
      wilaya: res.wilaya,
      originalPrice: res.originalPrice,
      price: res.price,
    })
    .execute();

  const { x: centerX, y: centerY } = calculateSquareCenter(
    res.longitude,
    res.latitude,
    30
  );

  const zoneName = `${centerX},${centerY}`;
  const zoneRef = firestore.collection("zones").doc(zoneName);
  try {
    await zoneRef.update({
      [`quantities.${insertId}`]: 0,
    });
  } catch (error) {
    await zoneRef.set({
      quantities: {
        [insertId]: 0,
      },
    });
  }

  return NextResponse.json({ res });
}
