export const calculateSquareCenter = (
  x: number,
  y: number,
  squareSpace: number
) => {
  const degreesPerKm = 1 / 111.32; // Approximate degrees per kilometer
  const squareSpaceDegrees = squareSpace * degreesPerKm;

  // Calculate rounded x and y coordinates
  const roundedX = Math.round(x / squareSpaceDegrees) * squareSpaceDegrees;
  const roundedY = Math.round(y / squareSpaceDegrees) * squareSpaceDegrees;

  // Calculate center coordinates
  const centerX = roundedX + squareSpaceDegrees / 2;
  const centerY = roundedY + squareSpaceDegrees / 2;

  return { x: Math.round(centerX * 1000), y: Math.round(centerY * 1000) };
};

export const reverseCalculateSquareCenter = (
  x: number,
  y: number,
  squareSpace: number
) => {
  const degreesPerKm = 1 / 111.32; // Approximate degrees per kilometer
  const squareSpaceDegrees = squareSpace * degreesPerKm;

  // Convert input x and y back to the original scale
  const centerX = x / 1000;
  const centerY = y / 1000;

  // Calculate the rounded x and y coordinates
  const roundedX = centerX - squareSpaceDegrees / 2;
  const roundedY = centerY - squareSpaceDegrees / 2;

  return { x: roundedX, y: roundedY };
  // todo this function does not work properly!!
};

export const addKilometersToLongitude = (
  longitude: number,
  kilometers: number
) => {
  const degreesPerKm = 1 / 111.32; // Approximate degrees per kilometer
  const distanceInDegrees = kilometers * degreesPerKm;
  const newLongitude = longitude + distanceInDegrees;
  return newLongitude;
};

export const calculateDistance = (
  point1: {
    latitude: number;
    longitude: number;
  },
  point2: {
    latitude: number;
    longitude: number;
  }
) => {
  const toRadians = (degrees: number) => {
    return (degrees * Math.PI) / 180;
  };

  const earthRadius = 6371; // in kilometers

  const dLat = toRadians(point2.latitude - point1.latitude);
  const dLon = toRadians(point2.longitude - point1.longitude);

  const a =
    Math.pow(Math.sin(dLat / 2), 2) +
    Math.cos(toRadians(point1.latitude)) *
      Math.cos(toRadians(point2.latitude)) *
      Math.pow(Math.sin(dLon / 2), 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  const distance = earthRadius * c;
  return distance;
};
