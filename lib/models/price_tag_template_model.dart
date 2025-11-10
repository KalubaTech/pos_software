class PriceTagTemplate {
  final String id;
  final String name;
  final double width; // in mm
  final double height; // in mm
  final List<PriceTagElement> elements;
  final DateTime createdAt;
  final DateTime updatedAt;

  PriceTagTemplate({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.elements,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'width': width,
      'height': height,
      'elements': elements.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PriceTagTemplate.fromJson(Map<String, dynamic> json) {
    return PriceTagTemplate(
      id: json['id'],
      name: json['name'],
      width: json['width'],
      height: json['height'],
      elements: (json['elements'] as List)
          .map((e) => PriceTagElement.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  PriceTagTemplate copyWith({
    String? id,
    String? name,
    double? width,
    double? height,
    List<PriceTagElement>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PriceTagTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      elements: elements ?? this.elements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ElementType {
  text,
  barcode,
  qrCode,
  image,
  line,
  rectangle,
  price,
  productName,
}

class PriceTagElement {
  final String id;
  final ElementType type;
  final double x; // Position X in mm
  final double y; // Position Y in mm
  final double width; // Width in mm
  final double height; // Height in mm
  final String? text;
  final double fontSize;
  final String fontFamily;
  final bool bold;
  final bool italic;
  final String textAlign; // 'left', 'center', 'right'
  final String?
  dataField; // Field name for dynamic data (e.g., 'productName', 'price')
  final String color; // Hex color
  final double rotation; // Rotation in degrees
  final double borderWidth;
  final String borderColor;
  final bool fillBackground;
  final String backgroundColor;
  final int zIndex; // Stacking order (higher = on top)
  final String? barcodeData; // Data for barcode/QR code
  final String barcodeType; // Type of barcode (code128, qr, ean13, etc.)

  PriceTagElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.text,
    this.fontSize = 12,
    this.fontFamily = 'Arial',
    this.bold = false,
    this.italic = false,
    this.textAlign = 'left',
    this.dataField,
    this.color = '#000000',
    this.rotation = 0,
    this.borderWidth = 0,
    this.borderColor = '#000000',
    this.fillBackground = false,
    this.backgroundColor = '#FFFFFF',
    this.zIndex = 0,
    this.barcodeData,
    this.barcodeType = 'code128',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'text': text,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'bold': bold,
      'italic': italic,
      'textAlign': textAlign,
      'dataField': dataField,
      'color': color,
      'rotation': rotation,
      'borderWidth': borderWidth,
      'borderColor': borderColor,
      'fillBackground': fillBackground,
      'backgroundColor': backgroundColor,
      'zIndex': zIndex,
      'barcodeData': barcodeData,
      'barcodeType': barcodeType,
    };
  }

  factory PriceTagElement.fromJson(Map<String, dynamic> json) {
    return PriceTagElement(
      id: json['id'],
      type: ElementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      text: json['text'],
      fontSize: json['fontSize'] ?? 12,
      fontFamily: json['fontFamily'] ?? 'Arial',
      bold: json['bold'] ?? false,
      italic: json['italic'] ?? false,
      textAlign: json['textAlign'] ?? 'left',
      dataField: json['dataField'],
      color: json['color'] ?? '#000000',
      rotation: json['rotation'] ?? 0,
      borderWidth: json['borderWidth'] ?? 0,
      borderColor: json['borderColor'] ?? '#000000',
      fillBackground: json['fillBackground'] ?? false,
      backgroundColor: json['backgroundColor'] ?? '#FFFFFF',
      zIndex: json['zIndex'] ?? 0,
      barcodeData: json['barcodeData'],
      barcodeType: json['barcodeType'] ?? 'code128',
    );
  }

  PriceTagElement copyWith({
    String? id,
    ElementType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    String? text,
    double? fontSize,
    String? fontFamily,
    bool? bold,
    bool? italic,
    String? textAlign,
    String? dataField,
    String? color,
    double? rotation,
    double? borderWidth,
    String? borderColor,
    bool? fillBackground,
    String? backgroundColor,
    int? zIndex,
    String? barcodeData,
    String? barcodeType,
  }) {
    return PriceTagElement(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      textAlign: textAlign ?? this.textAlign,
      dataField: dataField ?? this.dataField,
      color: color ?? this.color,
      rotation: rotation ?? this.rotation,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      fillBackground: fillBackground ?? this.fillBackground,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      zIndex: zIndex ?? this.zIndex,
      barcodeData: barcodeData ?? this.barcodeData,
      barcodeType: barcodeType ?? this.barcodeType,
    );
  }
}
