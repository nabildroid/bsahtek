import {
  serial,
  mysqlTable,
  text,
  varchar,
  json,
  double,
  int,
} from "drizzle-orm/mysql-core";

export const foodTable = mysqlTable("foods", {
  id: int("id").primaryKey().autoincrement(),
  name: varchar("name", { length: 255 }).notNull(),
  description: text("description"),
  foodPhoto: varchar("food_photo", { length: 255 }).notNull(),
  category: varchar("category", { length: 255 }).notNull(),
  tags: json("tags").notNull(),
  sellerName: varchar("seller_name", { length: 255 }).notNull(),
  sellerAddress: varchar("seller_address", { length: 255 }).notNull(),
  wilaya: varchar("wilaya", { length: 255 }).notNull(),
  county: varchar("county", { length: 255 }).notNull(),
  sellerPhoto: varchar("seller_photo", { length: 255 }).notNull(),
  latitude: double("latitude").notNull(),
  longitude: double("longitude").notNull(),
  zoomScale: double("zoom_scale").notNull(),
  rating: double("rating").notNull(),
});
