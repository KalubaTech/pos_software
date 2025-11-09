class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}