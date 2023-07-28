import * as z from "zod";
import * as Schema from "@/db/schema";
import { InferModel } from "drizzle-orm";

export const Stats = z.object({
  lastUpdated: z.string().transform((val) => new Date(val)),
  today: z.object({
    day: z.object({
      deliversRequests: z.number(),
      sellersRequests: z.number(),
      delivered: z.number(),
      orders: z.number(),
      selled: z.number(),
      newClients: z.number(),
    }),
  }),
});

export type IStats = z.infer<typeof Stats>;

export type IBag = InferModel<typeof Schema.bagsTable>;
