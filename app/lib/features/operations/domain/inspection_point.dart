/// Inspection condition status for vehicle body components
enum InspectionCondition {
  good,
  minorScratch,
  damaged,
}

/// Represents an item in the standard 8-point vehicle handover inspection
class InspectionPoint {
  final String id;
  final String defaultLabel;
  final InspectionCondition condition;
  final String notes;

  const InspectionPoint({
    required this.id,
    required this.defaultLabel,
    this.condition = InspectionCondition.good,
    this.notes = '',
  });

  InspectionPoint copyWith({
    InspectionCondition? condition,
    String? notes,
  }) {
    return InspectionPoint(
      id: id,
      defaultLabel: defaultLabel,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'default_label': defaultLabel,
        'condition': condition.name,
        'notes': notes,
      };

  factory InspectionPoint.fromJson(Map<String, dynamic> json) {
    return InspectionPoint(
      id: json['id'] as String? ?? '',
      defaultLabel: json['default_label'] as String? ?? '',
      condition: InspectionCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => InspectionCondition.good,
      ),
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Default 8-point inspection checklist required by AFOS SOP
  static List<InspectionPoint> createDefaultChecklist() {
    return const [
      InspectionPoint(id: 'front_bumper', defaultLabel: 'Bumper Depan'),
      InspectionPoint(id: 'rear_bumper', defaultLabel: 'Bumper Belakang'),
      InspectionPoint(id: 'left_body', defaultLabel: 'Bodi Sisi Kiri'),
      InspectionPoint(id: 'right_body', defaultLabel: 'Bodi Sisi Kanan'),
      InspectionPoint(id: 'windshield', defaultLabel: 'Kaca Depan & Jendela'),
      InspectionPoint(id: 'tires_wheels', defaultLabel: 'Ban & Velg (4 Roda)'),
      InspectionPoint(id: 'interior_cabin', defaultLabel: 'Interior & AC'),
      InspectionPoint(id: 'trunk_spare', defaultLabel: 'Bagasi & Ban Cadangan'),
    ];
  }
}
