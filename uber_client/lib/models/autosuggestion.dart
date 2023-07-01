import 'bag.dart';

class Autosuggestion {
  final String name;
  final String type;
  final String id;

  Autosuggestion({
    required this.name,
    required this.type,
    required this.id,
  });

  factory Autosuggestion.fromJson(Map<String, dynamic> json) {
    return Autosuggestion(
      name: json['name'],
      type: json['type'],
      id: json['id'],
    );
  }

  List<Bag> filter(List<Bag> bag) {
    return bag;
  }
}
