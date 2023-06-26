import db from "./db";
import { foodTable } from "../../../db/schema";


export async function addFood(data:any){

    db.insert(foodTable)

}