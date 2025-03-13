class FarmingLogEntry {
  final int? id;
  final int lotId;           // Khóa ngoại: liên kết FieldLot
  final String activityType; // gieo, bón phân, phun thuốc, thu hoạch,...
  final DateTime activityDate;
  final String description;  // Mô tả chi tiết
  final double cost;         // Chi phí (nếu có)
  final String images;       // Đường dẫn ảnh (có thể chuỗi JSON)
  final String notes;        // Ghi chú

  FarmingLogEntry({
    this.id,
    required this.lotId,
    required this.activityType,
    required this.activityDate,
    required this.description,
    required this.cost,
    required this.images,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lotId': lotId,
      'activityType': activityType,
      'activityDate': activityDate.toIso8601String(),
      'description': description,
      'cost': cost,
      'images': images,
      'notes': notes,
    };
  }

  factory FarmingLogEntry.fromMap(Map<String, dynamic> map) {
    return FarmingLogEntry(
      id: map['id'],
      lotId: map['lotId'],
      activityType: map['activityType'],
      activityDate: DateTime.parse(map['activityDate']),
      description: map['description'],
      cost: map['cost'],
      images: map['images'],
      notes: map['notes'],
    );
  }
}
