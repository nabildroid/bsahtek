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

// accept seller and assign them a bag
export async function POST(request: Request) {
  if (await AdminBlocForNot(["seller_accept"], request))
    return VerificationError();

  const demand = NewSeller.parse(await request.json());

  const userData = {
    displayName: demand.name,
  } as any;
  if (demand.phone) userData.phoneNumber = demand.phone;
  const user = await firebase.auth().createUser(userData);
  const sellerID = user.uid;
  const sellerRef = firebase.firestore().collection("sellers").doc(sellerID);

  await sellerRef.set({
    active: true,
    address: demand.address,
    country: demand.country,
    name: demand.name,
    phone: (demand.phone || null) as any,
    photo: demand.photo,
    storeAddress: demand.storeAddress,
    storeName: demand.storeName,
    storeType: demand.storeType,
    wilaya: demand.wilaya,
  } satisfies ISeller);

  const bagData = {
    sellerID: sellerID,
    latitude: demand.latitude,
    longitude: demand.longitude,
    category: demand.bagCategory,
    description: demand.bagDescription,
    name: demand.bagName,
    photo: demand.bagPhoto,
    price: demand.bagPrice,
    county: demand.country,
    wilaya: demand.wilaya,
    isPromoted: false,
    originalPrice: demand.bagOriginalPrice,
    sellerAddress: demand.address,
    sellerName: demand.name,
    sellerPhone: demand.phone,
    sellerPhoto: demand.photo,
    tags: demand.bagTags,
  } satisfies Partial<IBag>;

  // todo update userClaims
  // todo update the user informations

  const sellerZone = calculateSquareCenter(
    demand.longitude,
    demand.latitude,
    30
  );

  const zoneID = `${sellerZone.x},${sellerZone.y}`;
  revalidateTag(`foods-zone-${zoneID}`);
  console.log("Map zoneID to be revalidated", `foods-zone-${zoneID}`);

  const { insertId } = await db
    .insert(Schema.bagsTable)
    .values(bagData)
    .execute();

  // update the quantities
  await firebase
    .firestore()
    .collection("zones")
    .doc(zoneID)
    .set(
      {
        quantities: {
          [insertId]: admin.firestore.FieldValue.increment(0),
        },
      },
      { merge: true }
    );

  try {
    await firebase.auth().setCustomUserClaims(sellerID, {
      role: "seller",
    });
    // todo update also the informations
  } catch (e) {
    console.log("how the seller user doesn't exists?", sellerID);
  }

  return NextResponse.json({ success: true });
}
