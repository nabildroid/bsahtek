class Ad {
  final String id;
  final String photo;
  final String link;
  final String location;

  Ad({
    required this.id,
    required this.photo,
    required this.link,
    required this.location,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      photo: json['photo'],
      link: json['name'],
      location: json['location'],
    );
  }
}
