import db from "./db";
import { bagsTable } from "../../../db/schema";


export async function addFood(data:any){

    db.insert(bagsTable)

}