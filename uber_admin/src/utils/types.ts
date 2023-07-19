import * as z from "zod";
import * as Schema from "@/db/schema";

/**
 * final String id;
  final int quantity;

  final DateTime lastUpdate;
  final DateTime createdAt;

  final String clientID;
  final String clientName;
  final String clientPhone;
  final LatLng clientAddress;
  final String clientTown;

  final String sellerID;
  final LatLng sellerAddress;

  final String bagID;
  final String bagName;
  final String bagImage;
  final String bagPrice;
  final String bagDescription;

  final String? reportId;

  final bool isDelivred;
  final Map<String, LatLng>? deliveryPath;
  final String? deliveryManID;
  final String? deliveryPhone;
  final String? deliveryName;
  final DateTime? acceptedAt;

 */

export const Order = z.object({
  id: z.string(),
  quantity: z.number().min(1).max(10),
  lastUpdate: z.string().transform((a) => new Date(a)),
  createdAt: z.string().transform((a) => new Date(a)),

  clientID: z.string(),
  clientName: z.string(),
  clientPhone: z.string(),
  clientAddress: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),
  clientTown: z.string(),

  sellerID: z.string(),
  sellerAddress: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),

  bagID: z.string(),
  bagName: z.string(),
  bagImage: z.string(),
  bagPrice: z.string(),
  bagDescription: z.string(),

  reportId: z.string().optional(),

  isDelivered: z.boolean().optional(),
  deliveryPath: z
    .record(
      z.object({
        latitude: z.number(),
        longitude: z.number(),
      })
    )
    .optional(),
  deliveryManID: z.string().optional(),
  deliveryPhone: z.string().optional(),
  deliveryName: z.string().optional(),
  acceptedAt: z
    .string()
    .transform((a) => new Date(a))
    .optional(),

  isPickup: z.boolean(),
});

export type IOrder = z.infer<typeof Order>;

export const StartDeliveryOrder = Order.extend({
  deliveryManID: z.string(),
  deliveryPhone: z.string(),
  deliveryName: z.string(),
  isPickup: z.literal(false),
  deliveryAddress: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),
}).omit({
  isDelivered: true,
  deliveryPath: true,
  reportId: true,
});

export const AcceptOrder = Order.extend({
  acceptedAt: z.string().transform((a) => new Date(a)),
}).omit({
  isDelivered: true,
  deliveryPath: true,
  deliveryManID: true,
  deliveryPhone: true,
  deliveryName: true,

  reportId: true,
});

export const HandOver = Order.extend({
  acceptedAt: z.string().transform((a) => new Date(a)),
}).omit({
  isDelivered: true,
  reportId: true,
  deliveryPath: true,
});

export const NewOrder = Order.extend({}).omit({
  id: true,
  acceptedAt: true,
  reportId: true,

  isDelivered: true,
  deliveryPath: true,
  deliveryManID: true,
  deliveryPhone: true,
  deliveryName: true,
});

export const NewFood = z.object({
  name: z.string(),

  description: z.string(),
  photo: z.string(),
  category: z.string(),
  tags: z.array(z.string()).default([]),
  sellerName: z.string(),
  sellerAddress: z.string(),
  sellerID: z.string(),
  sellerPhoto: z.string(),
  wilaya: z.string(),
  county: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  isPromoted: z.boolean(),
  originalPrice: z.number(),
  price: z.number(),
} satisfies Partial<{ [key in keyof typeof Schema.bagsTable]: any }>);

export const Track = z.object({
  id: z.string(),
  orderID: z.string(),
  deliveryManID: z.string(),
  clientID: z.string(),
  sellerID: z.string(),
  deliverLocation: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }),
  sellerLocation: z.object({
    // being used to calculate distance and then notify the seller!
    latitude: z.number(),
    longitude: z.number(),
  }),
  clientLocation: z.object({
    // being used to calculate distance and then notify the seller!
    latitude: z.number(),
    longitude: z.number(),
  }),
  toClient: z.boolean(), // delivery need to confirm
  toSeller: z.boolean(), // seller need to confirm

  path: z
    .array(
      z.object({
        latitude: z.number(),
        longitude: z.number(),
      })
    )
    .default([]),

  updatedAt: z.string().transform((a) => new Date(a)),
  createdAt: z.string().transform((a) => new Date(a)),
});

export type ITrack = z.infer<typeof Track>;

export const Tracking = Track.omit({
  createdAt: true,
  path: true,
  toClient: true,
  toSeller: true,
  updatedAt: true,
});

export const SellerRequest = z.object({
  id: z.string().optional(),
  name: z.string(),
  phone: z.string(),
  address: z.string(),
  wilaya: z.string(),
  country: z.string(),
  storeType: z.string(),
  storeName: z.string(),
  storeAddress: z.string(),
  photo: z.string(),
  active: z.boolean().default(false),
});

export const DeliverRequest = z.object({
  id: z.string().optional(),
  name: z.string(),
  phone: z.string(),
  address: z.string(),
  wilaya: z.string(),
  country: z.string(),
  photo: z.string(),

  active: z.boolean().default(false),
});

export type ISellerRequest = z.infer<typeof SellerRequest>; // todo change the name of this Type of be SellerProfile ..
export type IDeliverRequest = z.infer<typeof DeliverRequest>; // todo change the name of this Type of be SellerProfile ..
