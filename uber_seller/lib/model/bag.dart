import 'order.dart';

class Bag {
  final int id;
  final String name;
  final String description;
  final String photo;
  final String category;
  final String tags;
  final String sellerName;
  final String sellerAddress;
  final String sellerID;
  final String sellerPhoto;
  final String wilaya;
  final String county;
  final double latitude;
  final double longitude;
  final bool isPromoted;
  final double originalPrice;
  final double price;
  final double rating;

  Bag({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.category,
    required this.tags,
    required this.sellerName,
    required this.sellerAddress,
    required this.sellerID,
    required this.sellerPhoto,
    required this.wilaya,
    required this.county,
    required this.latitude,
    required this.longitude,
    required this.isPromoted,
    required this.originalPrice,
    required this.price,
    required this.rating,
  });

  String get idd => '$longitude,$latitude';

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      photo: json['photo'],
      category: json['category'],
      tags: json['tags'],
      sellerName: json['sellerName'],
      sellerAddress: json['sellerAddress'],
      sellerID: json['sellerID'],
      sellerPhoto: json['sellerPhoto'],
      wilaya: json['wilaya'],
      county: json['county'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      isPromoted: json['isPromoted'],
      originalPrice: double.parse(json['originalPrice'].toString()),
      price: double.parse(json['price'].toString()),
      rating: double.parse((json['rating'] ?? 4).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo': photo,
      'category': category,
      'tags': tags,
      'sellerName': sellerName,
      'sellerAddress': sellerAddress,
      'sellerID': sellerID,
      'sellerPhoto': sellerPhoto,
      'wilaya': wilaya,
      'county': county,
      'latitude': latitude,
      'longitude': longitude,
      'isPromoted': isPromoted,
      'originalPrice': originalPrice,
      'price': price,
      'rating': rating,
    };
  }
}
