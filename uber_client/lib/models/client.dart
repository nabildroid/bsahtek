class Client {
  final String id;
  final String name;
  final String phone;
  final String photo;
  final bool isActive;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.photo,
    this.isActive = false,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      photo: json['photo'],
      isActive: json['isActive'],
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo': photo,
      'isActive': isActive,
    };
  }

  Client copyWith({
    String? name,
    String? photo,
    String? phone,
  }) {
    return Client(
      id: this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
    );
  }
}
