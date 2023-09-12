import Cookies from "js-cookie";
import Axios from "axios";
import * as Schema from "@/db/schema";

import AuthClient from "./auth";

import { getIdToken } from "firebase/auth";
import { IBag, IStats } from "@/types";
import { InferModel } from "drizzle-orm";
import {
  IAcceptSeller,
  IClient,
  IDeliver,
  IOrder,
  ISeller,
} from "@/utils/types";

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
  const { data } = await Http.get(`/admin/sellers/${sellerID}`);
  return data as {
    bags: IBag[];
    seller: ISeller;
  };
}

export async function sellerDetails(sellerID: string) {
  const { data } = await Http.get(`/admin/sellers/${sellerID}/details`);
  return data as {
    orders: IOrder[];
    seller: ISeller;
  };
}

export async function deliverDetails(deliverID: string) {
  const { data } = await Http.get(`/admin/delivers/${deliverID}/details`);
  return data as {
    orders: IOrder[];
    deliver: ISeller;
  };
}

export async function sellerRequests() {
  const { data } = await Http.get("/admin/sellers/requests");
  return data.requests as ISeller[];
}

export async function deliverRequests() {
  const { data } = await Http.get("/admin/delivers/requests");
  return data.requests as IDeliver[];
}

export async function clientRequests() {
  const { data } = await Http.get("/admin/clients/requests");
  return data.requests as IClient[];
}

export async function acceptClient(demand: IClient) {
  const { data } = await Http.post(`/admin/clients/${demand.id}`, {
    ...demand,
    active: true,
  });
  return data;
}

export async function rejectClient(demand: IClient) {
  const { data } = await Http.post(`/admin/clients/${demand.id}`, {
    ...demand,
    active: false,
  } as IClient);
  return data;
}

export async function delivers() {
  const { data } = await Http.get("/admin/delivers");
  return data.delivers as IDeliver[];
}

export async function deliver(deliverID: string) {
  const { data } = await Http.get(`/admin/delivers/${deliverID}`);
  return data.deliver as IDeliver;
}

export async function updateSeller(sellerID: string, demand: IAcceptSeller) {
  const { data } = await Http.post(`/admin/sellers/${sellerID}`, demand);
  return data;
}

export async function removeSeller(sellerID: string) {
  const { data } = await Http.delete(`/admin/sellers/${sellerID}`);
  return data;
}

export async function acceptDeliver(deliverID: string, demand: IDeliver) {
  const { data } = await Http.post(`/admin/delivers/${deliverID}`, demand);
  return data;
}
export async function getOrders() {
  const { data } = await Http.get(`/admin/orders`);

  return data.orders as IOrder[];
}

