class Client {
  final String id;
  final String name;
  final String phone;
  final String photo;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.photo,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      photo: json['photo'],
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo': photo,
    };
  }

  Client copyWith({
    String? name,
    String? photo,
  }) {
    return Client(
      id: this.id,
      name: name ?? this.name,
      phone: this.phone,
      photo: photo ?? this.photo,
    );
  }
}
