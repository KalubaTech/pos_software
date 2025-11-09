class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'category',
    this.color = '#009688',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? 'category',
      color: json['color'] ?? '#009688',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'color': color,
    };
  }
}
