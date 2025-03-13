class FieldLot {
  final int? id;
  final String lotCode;        // Mã lô
  final double area;           // Diện tích
  final String status;         // Tình trạng (đang gieo, đang chăm sóc, đã thu hoạch,...)
  final DateTime sowDate;      // Ngày gieo
  final DateTime? harvestDate; // Ngày thu hoạch (nếu có)

  FieldLot({
    this.id,
    required this.lotCode,
    required this.area,
    required this.status,
    required this.sowDate,
    this.harvestDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lotCode': lotCode,
      'area': area,
      'status': status,
      'sowDate': sowDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
    };
  }

  factory FieldLot.fromMap(Map<String, dynamic> map) {
    return FieldLot(
      id: map['id'],
      lotCode: map['lotCode'],
      area: map['area'],
      status: map['status'],
      sowDate: DateTime.parse(map['sowDate']),
      harvestDate: map['harvestDate'] != null
          ? DateTime.parse(map['harvestDate'])
          : null,
    );
  }
}
