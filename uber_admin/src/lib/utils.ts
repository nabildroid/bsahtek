import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function convertDatesToMonthStats(dates: Date[]) {
  // get the latest date, from there go back 29 days
  // all same dates (year,month,day) sum them
  // the output is {date:Date, count:number}[] (where the array contain the latest 30 days)

  console.log(dates);
  const today =
    dates.length == 0
      ? new Date()
      : dates.sort((a, b) => a.getTime() - b.getTime())[dates.length - 1];
  console.log(today);
  const latestDate = new Date(
    today.getFullYear(),
    today.getMonth(),
    today.getDate()
  );
  const oldestDate = new Date(
    today.getFullYear(),
    today.getMonth(),
    today.getDate() - 29
  );

  const datesMap: Map<string, number> = new Map();
  dates.forEach((date) => {
    const dateKey = date.toDateString();
    const count = datesMap.get(dateKey) ?? 0;
    datesMap.set(dateKey, count + 1);
  });

  const monthStats: { date: Date; count: number }[] = [];

  for (
    let date = latestDate;
    date >= oldestDate;
    date.setDate(date.getDate() - 1)
  ) {
    const dateKey = date.toDateString();
    const count = datesMap.get(dateKey) ?? 0;
    monthStats.push({ date: new Date(date), count });
  }

  console.log(monthStats);

  return monthStats
    .map((item) => ({
      x: `${item.date.getDate()}/${item.date.getMonth() + 1}`,
      y: item.count,
    }))
    .reverse();
}
