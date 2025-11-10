class PrinterModel {
  final String id;
  final String name;
  final PrinterType type;
  final ConnectionType connectionType;
  final String? address; // IP address or Bluetooth address
  final int? port; // For network printers
  final int paperWidth; // in mm (58 or 80)
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrinterModel({
    required this.id,
    required this.name,
    required this.type,
    required this.connectionType,
    this.address,
    this.port,
    this.paperWidth = 80,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  PrinterModel copyWith({
    String? id,
    String? name,
    PrinterType? type,
    ConnectionType? connectionType,
    String? address,
    int? port,
    int? paperWidth,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrinterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      connectionType: connectionType ?? this.connectionType,
      address: address ?? this.address,
      port: port ?? this.port,
      paperWidth: paperWidth ?? this.paperWidth,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'connectionType': connectionType.name,
      'address': address,
      'port': port,
      'paperWidth': paperWidth,
      'isDefault': isDefault ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      id: json['id'],
      name: json['name'],
      type: PrinterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PrinterType.thermal,
      ),
      connectionType: ConnectionType.values.firstWhere(
        (e) => e.name == json['connectionType'],
        orElse: () => ConnectionType.usb,
      ),
      address: json['address'],
      port: json['port'],
      paperWidth: json['paperWidth'] ?? 80,
      isDefault: json['isDefault'] == 1,
      isActive: json['isActive'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum PrinterType { thermal, inkjet, laser }

enum ConnectionType { usb, network, bluetooth }
