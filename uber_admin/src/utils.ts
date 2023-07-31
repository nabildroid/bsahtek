export function setLoginToken(token: string) {
  document.cookie = `token=${token}`;
  document.cookie = `isLogged=true`;

  return "/?authorized";
}

export function ago(startDate: Date) {
  const currentTime = new Date();
  const timeDiff = currentTime.getTime() - startDate.getTime();
  const minute = 60 * 1000;
  const hour = 60 * minute;
  const day = 24 * hour;

  if (timeDiff < 1 * minute) {
    return "Just now";
  } else if (timeDiff < 5 * minute) {
    return "Last minute";
  } else if (timeDiff < 10 * minute) {
    return "5 minutes ago";
  } else if (timeDiff < 30 * minute) {
    return "10 minutes ago";
  } else if (timeDiff < 60 * minute) {
    return "30 minutes ago";
  } else if (timeDiff < 2 * hour) {
    return "1 hour ago";
  } else if (timeDiff < 4 * hour) {
    return "3 hours ago";
  } else if (timeDiff < day) {
    return "Earlier today";
  } else if (timeDiff < 2 * day) {
    return "Yesterday";
  } else {
    const year = startDate.getFullYear();
    const month = String(startDate.getMonth() + 1).padStart(2, "0");
    const date = String(startDate.getDate()).padStart(2, "0");
    return `${date}/${month}/${year}`;
  }
}

export function diffInMin(date1: Date, date2: Date) {
  return Math.abs(Math.floor((date2.getTime() - date1.getTime()) / 60000));
}

type Loc = {
  lat: number;
  lng: number;
};
//https://cloud.google.com/blog/products/maps-platform/how-calculate-distances-map-maps-javascript-api
export function haversine_distance(mk1: Loc, mk2: Loc) {
  var R = 6371.071; // Radius of the Earth in miles
  var rlat1 = mk1.lat * (Math.PI / 180); // Convert degrees to radians
  var rlat2 = mk2.lat * (Math.PI / 180); // Convert degrees to radians
  var difflat = rlat2 - rlat1; // Radian difference (latitudes)
  var difflon = (mk2.lng - mk1.lng) * (Math.PI / 180); // Radian difference (longitudes)

  var d =
    2 *
    R *
    Math.asin(
      Math.sqrt(
        Math.sin(difflat / 2) * Math.sin(difflat / 2) +
          Math.cos(rlat1) *
            Math.cos(rlat2) *
            Math.sin(difflon / 2) *
            Math.sin(difflon / 2)
      )
    );
  return d;
}

export function pricePerDistance(distance: number) {
  if (distance < 1) return 10;
  else if (distance < 5) return 20;
  else if (distance < 10) return 30;
  else if (distance < 15) return 40;
  else if (distance < 20) return 50;
  else if (distance < 25) return 60;
  else if (distance < 30) return 70;
  else if (distance < 35) return 80;
  else if (distance < 40) return 90;
  else return 100;
}
