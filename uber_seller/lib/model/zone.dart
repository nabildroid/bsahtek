class Zone {
  final String id;
  final Map<String, int> quantities;

  Zone({
    required this.id,
    required this.quantities,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      quantities: Map<String, int>.from(json['quantities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantities': quantities,
    };
  }
}
