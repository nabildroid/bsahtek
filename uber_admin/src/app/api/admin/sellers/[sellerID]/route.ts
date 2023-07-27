import db from "@/app/api/repository/db";
import { eq } from "drizzle-orm";
import firebase, {
  BlocForNot,
  VerificationError,
} from "@/app/api/repository/firebase";
import { AcceptSeller, ISeller, Seller } from "@/utils/types";
import { NextResponse } from "next/server";
import * as Schema from "@/db/schema";
import { IBag } from "@/types";

export const dynamic = "force-dynamic";

type Context = {
  params: {
    sellerID: string;
  };
};
// get details of a seller
export async function GET(request: Request, context: Context) {
  if (await BlocForNot("admin", request)) return VerificationError();
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

  console.log(data);

  let bags = [] as any[];
  if (data.active) {
    bags = await db
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
export async function POST(request: Request, context: Context) {
  if (await BlocForNot("admin", request)) return VerificationError();
  const { sellerID } = context.params;
  const demand = AcceptSeller.parse(await request.json());
  if (sellerID !== demand.id)
    return new Response("Bad Request", { status: 400 });

  const sellerRef = firebase.firestore().collection("sellers").doc(sellerID);
  await sellerRef.update({
    active: true,
    address: demand.address,
    country: demand.country,
    name: demand.name,
    phone: demand.phone,
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
    rating: 0,
    sellerAddress: demand.address,
    sellerName: demand.name,
    sellerPhone: demand.phone,
    sellerPhoto: demand.photo,
    tags: demand.bagTags,
  } satisfies Partial<IBag>;

  // todo update userClaims

  if (demand.bagID) {
    await db
      .update(Schema.bagsTable)
      .set(bagData)
      .where(eq(Schema.bagsTable.id, demand.bagID))
      .execute();
    // update
  } else {
    // insert
    await db.insert(Schema.bagsTable).values(bagData).execute();
  }

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

export async function DELETE(request: Request, context: Context) {
  if (await BlocForNot("admin", request)) return VerificationError();
  const { sellerID } = context.params;

  const sellerRef = firebase.firestore().collection("sellers").doc(sellerID);
  await sellerRef.delete();

  try {
    await firebase.auth().deleteUser(sellerID);
    // todo update also the informations
  } catch (e) {
    console.log("how the seller user doesn't exists?", sellerID);
  }

  return NextResponse.json({ success: true });
}
