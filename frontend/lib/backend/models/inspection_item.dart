class InspectionItem {
  final String name;
  final String status; // 'OK', 'Attention', 'Critical', 'Not Checked'
  final String? notes;
  final List<String> photoPaths;

  InspectionItem({
    required this.name,
    required this.status,
    this.notes,
    this.photoPaths = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'notes': notes,
      'photoPaths': photoPaths,
    };
  }

  factory InspectionItem.fromMap(Map<String, dynamic> map) {
    return InspectionItem(
      name: map['name'],
      status: map['status'],
      notes: map['notes'],
      photoPaths: List<String>.from(map['photoPaths'] ?? []),
    );
  }
}
