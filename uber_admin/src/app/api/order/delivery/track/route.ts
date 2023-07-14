import { IOrder, NewOrder, Order } from "@/utils/types";
import * as admin from "firebase-admin";
import { TypeOf, z } from "zod";

const Props = z.object({
  orderID: z.string(),
  clientID: z.string(),
  currentLocation: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),

  startLocation: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),

  clientLocation: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),

  sellerLocation: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),

  toClient: z.boolean(),
});

export async function POST(request: Request) {
  const track = Props.parse(await request.json());

  return new Response(JSON.stringify(track));
}
