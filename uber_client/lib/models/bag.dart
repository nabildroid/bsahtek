// todo rename it to bags!
class Bag {
  final int id;
  final String name;
  final String description;
  final String bagPhoto;
  final String category;
  final String tags;
  final String sellerName;
  final String sellerAddress;
  final String wilaya;
  final String county;
  final String sellerPhoto;
  final double latitude;
  final double longitude;
  final double zoomScale;
  final double rating;

  Bag({
    required this.id,
    required this.name,
    required this.description,
    required this.bagPhoto,
    required this.category,
    required this.tags,
    required this.sellerName,
    required this.sellerAddress,
    required this.wilaya,
    required this.county,
    required this.sellerPhoto,
    required this.latitude,
    required this.longitude,
    required this.zoomScale,
    required this.rating,
  });

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      bagPhoto: json['foodPhoto'],
      category: json['category'],
      tags: json['tags'],
      sellerName: json['sellerName'],
      sellerAddress: json['sellerAddress'],
      wilaya: json['wilaya'],
      county: json['county'],
      sellerPhoto: json['sellerPhoto'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      zoomScale: double.parse((json['zoomScale'].toString())),
      rating: double.parse(json['rating'].toString()),
    );
  }
}
