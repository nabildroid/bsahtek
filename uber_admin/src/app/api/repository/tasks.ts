import axios from "axios";
import { date } from "zod";

const API = axios.create({
  baseURL: "https://qstash.upstash.io/v1/",
  headers: {
    Authorization: `Bearer ${process.env.QSTASH_TOKEN}`,
  },
});

export async function create(params: {
  url: string;
  data: any;
  delayInSeconds: number;
}) {
  const scheduledDate = new Date(Date.now() + params.delayInSeconds * 1000);

  const cronSchedule = `${scheduledDate.getUTCMinutes()} ${scheduledDate.getUTCHours()} ${scheduledDate.getUTCDate()} ${
    scheduledDate.getMonth() + 1
  } *`;

  const { data } = await API.post(`publish/${params.url}`, params.data, {
    headers: {
      "Upstash-Cron": cronSchedule,
    },
  });

  return data;
}

export async function getIdsByURLpartial(url: string) {
  const schedules = (await list()) as any[];

  return schedules
    .filter((schedule) => schedule.destination.url.includes(url))
    .map((schedule) => schedule.scheduleId) as string[];
}

export async function list() {
  const { data } = await API.get("/schedules");

  return data;
}

export async function remove(id: string) {
  const { data } = await API.delete(`schedules/${id}`);
}
