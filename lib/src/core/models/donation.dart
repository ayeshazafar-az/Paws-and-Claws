class Donation {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String status;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.userId,
    required this.amount,
    this.type = 'one-time',
    this.status = 'completed',
    required this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String? ?? 'one-time',
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
