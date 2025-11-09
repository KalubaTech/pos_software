enum StoreType {
  generic,
  restaurant,
  bar,
  grocery,
  butchery,
  drugStore,
}

class StoreModel {
  final String id;
  final String name;
  final String location;
  final StoreType type;
  final String description;
  final String contactNumber;
  final String email;
  final String address;
  final String clientId;

  StoreModel({
    required this.id,
    required this.name,
    required this.location,
    this.type = StoreType.generic,
    this.description = '',
    this.contactNumber = '',
    this.email = '',
    this.address = '',
    this.clientId = '',
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      type: _storeTypeFromString(json['type']),
      description: json['description'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      clientId: json['client_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type.name,
      'description': description,
      'contact_number': contactNumber,
      'email': email,
      'address': address,
      'client_id': clientId,
    };
  } 

  static StoreType _storeTypeFromString(String? typeString) {
    if (typeString == null) {
      return StoreType.generic;
    }
    try {
      return StoreType.values.byName(typeString);
    } catch (e) {
      return StoreType.generic;
    }
  }
}