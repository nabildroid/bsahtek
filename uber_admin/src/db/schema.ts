import { sql } from "drizzle-orm";
import {
  serial,
  mysqlTable,
  text,
  varchar,
  json,
  double,
  int,
  boolean,
  datetime,
} from "drizzle-orm/mysql-core";

export const bagsTable = mysqlTable("bags", {
  id: int("id").primaryKey().autoincrement(),
  name: varchar("name", { length: 255 }).notNull(),
  description: text("description"),
  photo: varchar("photo", { length: 255 }).notNull(),
  category: varchar("category", { length: 255 }).notNull(),
  tags:  varchar("tags", { length: 255 }).notNull(),
  sellerName: varchar("seller_name", { length: 255 }).notNull(),
  sellerAddress: varchar("seller_address", { length: 255 }).notNull(),
  sellerPhone: varchar("seller_phone", { length: 255 }).notNull().default("+2135656556545"), // todo remove the default
  sellerID: varchar("seller_id", { length: 255 }).notNull(),
  sellerPhoto: varchar("seller_photo", { length: 255 }).notNull(),
  wilaya: varchar("wilaya", { length: 50 }).notNull(),
  county: varchar("county", { length: 50 }).notNull(),
  latitude: double("latitude").notNull(),
  longitude: double("longitude").notNull(),
  rating: double("rating").notNull(),
  isPromoted: boolean("is_promoted").default(false),
  originalPrice: double("original_price").notNull(),
  price: double("price").notNull(),
});
