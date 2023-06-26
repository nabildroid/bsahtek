import { drizzle } from "drizzle-orm/planetscale-serverless";
import { connect } from "@planetscale/database";

// create the connection
const connection = connect({
  url: process.env.DB_URL,
});

export default drizzle(connection);
