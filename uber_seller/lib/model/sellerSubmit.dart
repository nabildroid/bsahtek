/**
 * name: z.string(),
  phone: z.string(),
  address: z.string(),
  wilaya: z.string(),
  country: z.string(),
  storeType: z.string(),
  storeName: z.string(),
  storeAddress: z.string(),
  photo: z.string(),
  active: z.boolean().default(false),
 */
class SellerSubmit {
  final String name;
  final String address;
  final String wilaya;
  final String country;
  final String storeType;
  final String storeName;
  final String storeAddress;
  final String phone;
  final String photo;
  final bool active;

  SellerSubmit({
    required this.name,
    required this.address,
    required this.wilaya,
    required this.country,
    required this.storeType,
    required this.storeName,
    required this.storeAddress,
    required this.phone,
    required this.photo,
    this.active = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'wilaya': wilaya,
      'country': country,
      'storeType': storeType,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'phone': phone,
      'photo': photo,
      'active': active,
    };
  }
}
