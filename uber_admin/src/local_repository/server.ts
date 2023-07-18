import Cookies from "js-cookie";
import Axios from "axios";

import AuthClient from "./auth";

import { getIdToken } from "firebase/auth";

const ENDPOINT =
  process.env.NODE_ENV === "production"
    ? process.env.NEXT_PUBLIC_ARIB_API || process.env.ARIB_API
    : "http://localhost:3001/api";

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

export async function getLines(): Promise<any> {
  const { data } = await Http.get("/chain/lines");
  return data.lines;
}
