// Actors

interface User {
  phoneNumber: string;
  name: string;
  photoUrl: string;
  email: string;
  uid: string;
}

interface Client extends User {
  address: string;
}

interface Seller extends User {
  address: string;
  company: string;
}

interface Deliver extends User {}

// Entities
interface Food {
  id: string;
  name: string;
  price: number;
  discount?: number;
  description?: string;
  mainPhoto: string;
  gallery?: string[];
  category: string;
  quantity: number;
  tags: string[];
}

interface Autosuggesting {
  id: string;
  title: string;
  preferedDate: Date;
  preferedTime: Date;
  preferedLocation: string;
  preferedTags: string[];
  preferedCategory: string;
  preferedPriceRange: number;
  preferedDistanceRange: number;
  preferedRatingRange: number;
  preferedQuantityRange: number;

  isSeller: boolean;

  scaleIfAlreadyOrdered: number;
  scaleIfAlreadyFav: number;
  scaleIfAlreadySearched: number;

  expiresAt: Date;
}

interface Basket {
  id: string;
  foods: Food[]; // they belong to the same seller
  createdDate: Date;
}

interface Order {
  id: string;
  basket: Basket;
  client: Client;
  seller: Seller;
  delivery?: Deliver;
  valide: true;

  createdDate: Date;
}

interface OrderStatus {
  id: string;
  confirmedBy?: Seller;
  deliveringBy?: Deliver;
  finished?: string;
  lastModified: Date;
}

// Business logic
interface SearchRawItem {
  id: string;
  name: string;
  description?: string;
  foodPhoto: string;
  category: string;
  tags: string[];

  sellerName: string;
  sellerAddress: string;
  wilaya: string;
  county: string;
  sellerPhoto: string;
  latitude: number;
  longitude: number;
  zoomScale: number;
  rating: number;
}

interface CellMetadata {
  cellId: string;
  latitude: number;
  longitude: number;
  lastModified: Date;
  zoomScale: number;
  foods: {
    [foodId: string]: {
      id: string;
      price: number;
      discount?: number;
      quantity: number;
    };
  }[];
}

interface DeliveryTask {
  id: string;
  order: Order;
  deliver: Deliver;
  client: Client;
  positions: {
    latitude: number;
    longitude: number;
    timestamp: Date;
  }[];

  startAt: Date;
  endsAt: Date;
  estimatedEndAt: Date;
  deliveryPrice: number;
}
