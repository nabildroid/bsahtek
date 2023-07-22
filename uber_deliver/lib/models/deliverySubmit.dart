class DeliverySubmit {
  final String name;
  final String country;
  final String wilaya;
  final String address;
  final String photo;

  const DeliverySubmit({
    required this.name,
    required this.country,
    required this.wilaya,
    required this.address,
    required this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'wilaya': wilaya,
      'address': address,
      'photo': photo,
    };
  }
}
