import 'base_model.dart';

class Item extends BaseModel {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic>? additionalData;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    this.additionalData,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (additionalData != null) ...additionalData!,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      additionalData: json..removeWhere((key, _) => 
        ['id', 'name', 'description'].contains(key)),
    );
  }
}
