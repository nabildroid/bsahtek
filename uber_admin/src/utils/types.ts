import * as z from "zod";
import * as Schema from "@/db/schema";
import secureHash from "@/app/api/utils";

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

 */

export const Order = z.object({
  id: z.string(),
  quantity: z.number().min(1).max(10),
  lastUpdate: z.string().transform((a) => new Date(a)),
  createdAt: z.string().transform((a) => {
    console.log(a, new Date(a));
    return new Date(a);
  }),

  clientID: z.string(),
  clientName: z.string(),
  clientPhone: z
    .string()
    .nonempty()
    .transform((p) => {
      if (p.startsWith("+213")) return p;
      else return "+213" + p.replaceAll(" ", "");
    }),
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

  sellerName: z.string(),
  sellerPhone: z.string(),
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

  isPickup: z.boolean(),

  timeslot: z
    .object({
      window: z.array(z.number()).length(2),
      hash: z.string(),
    })
    .optional(),
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


export const HandOverToClient = Order.extend({
  isPickup: z.literal(true),
}).omit({
  deliveryManID: true,
  deliveryPhone: true,
  deliveryName: true,

  isDelivered: true,
  reportId: true,
  deliveryPath: true,
});

export const HandOver = Order.extend({
  isPickup: z.literal(false),
  deliveryManID: z.string(),
  deliveryPhone: z.string(),
  deliveryName: z.string(),
}).omit({
  isDelivered: true,
  reportId: true,
  deliveryPath: true,
});

export const HandOverForAll = z.discriminatedUnion("isPickup", [
  HandOver,
  HandOverToClient,
]);

export const NewOrder = Order.extend({}).omit({
  id: true,
  reportId: true,

  isDelivered: true,
  deliveryPath: true,
  deliveryManID: true,
  deliveryPhone: true,
  deliveryName: true,

  sellerName: true,
  sellerPhone: true,
});

export type INewOrder = z.infer<typeof NewOrder>;



// todo add photo url refine
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
  updatedAt: true,
}).extend({
  toSeller: z.boolean().optional(),
});

export const Seller = z.object({
  id: z.string().optional(),
  name: z.string(),
  phone: z
    .string()
    .nonempty()
    .transform((p) => {
      if (p.startsWith("+213")) return p;
      else return "+213" + p.replaceAll(" ", "");
    }),
  address: z.string(),
  wilaya: z.string(),
  country: z.string(),
  storeType: z.string(),
  storeName: z.string(),
  storeAddress: z.string(),
  photo: z.string(),
  active: z.boolean().default(false),
});

export const Deliver = z.object({
  id: z.string().optional(),
  name: z.string(),
  phone: z.string(),
  address: z.string(),
  wilaya: z.string(),
  country: z.string(),
  photo: z.string(),

  active: z.boolean().default(false),
});

export const Client = z.object({
  id: z.string().optional(),
  name: z.string(),
  phone: z.string(),
  address: z.string(),
  photo: z.string(),
  email: z.string().optional().nullable(),

  active: z.boolean().default(false),

  requestedOrder: NewOrder,
  rejectionReason: z.string().optional(),
});

export const AcceptSeller = Seller.extend({
  active: z.literal(true),
  bagName: z.string(),
  bagDescription: z.string(),
  bagPrice: z.number(),
  bagOriginalPrice: z.number(),
  bagPhoto: z.string(),
  bagID: z.number().optional(),
  // not equal to zero or NaN
  latitude: z.number().refine((a) => a !== 0 && !isNaN(a)),
  longitude: z.number().refine((a) => a !== 0 && !isNaN(a)),
  bagCategory: z.string(),
  bagTags: z.string(),
});

export const NewSeller = AcceptSeller.omit({
  phone: true,
  bagID: true,
}).extend({
  phone: Seller.shape.phone.optional(),
});

export type INewSeller = z.infer<typeof NewSeller>;
export type IAcceptSeller = z.infer<typeof AcceptSeller>;

export type ISeller = z.infer<typeof Seller>;
export type IDeliver = z.infer<typeof Deliver>;
export type IClient = z.infer<typeof Client>;

export const OrderExpireTask = z.object({
  orderID: z.string(),
  bagID: z.number(),
  sellerID: z.string(),
  quantity: z.number(),
  clientID: z.string(),
  zone: z.string(),
});

export type IOrderExpireTask = z.infer<typeof OrderExpireTask>;

export const Ad = z.object({
  id: z.string().optional(),
  name: z.string().startsWith("https://"),
  photo: z.string(),
  location: z.enum([
    "home",
    "discover-center",
    "discover-top",
    "discover-bottom",
  ]),
  active: z.boolean().default(true),
});

export type IAd = z.infer<typeof Ad>;
