class Application {
  final String id;
  final String userId;
  final String animalId;
  final String status;
  final DateTime submittedAt;

  Application({
    required this.id,
    required this.userId,
    required this.animalId,
    this.status = 'pending',
    required this.submittedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      animalId: json['animal_id'] as String,
      status: json['status'] as String? ?? 'pending',
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'animal_id': animalId,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }
}
