import Cookies from "js-cookie";
import Axios from "axios";
import * as Schema from "@/db/schema";

import AuthClient from "./auth";

import { getIdToken } from "firebase/auth";
import { IBag, IStats } from "@/types";
import { InferModel } from "drizzle-orm";
import { ISellerRequest } from "@/utils/types";

const ENDPOINT = process.env.NODE_ENV === "production" ? "/api" : "/api";

const Http = Axios.create({
  baseURL: ENDPOINT,
});

Http.interceptors.request.use((config) => {
  const token = Cookies.get("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  return config;
});

const Auth = (customToken?: string) => ({
  Authorization: `Bearer ${customToken ?? Cookies.get("token") ?? ""}`,
});

export async function ping(): Promise<any> {
  const { data } = await Http.get("/admin/stats");
  return data.success;
}

export async function stats() {
  const { data } = await Http.get("/admin/stats");
  return data.stats as Partial<IStats>;
}

export async function sellers() {
  const { data } = await Http.get("/admin/sellers");
  return data.sellers as IBag[];
}

export async function seller(sellerID: string) {
  const { data } = await Http.get(`/admin/sellers/${sellerID}/`);
  return data as {
    bags: IBag[];
    seller: ISellerRequest;
  };
}
export async function sellerRequests() {
  const { data } = await Http.get("/admin/sellers/requests");
  return data.requests as ISellerRequest[];
}
