class Animal {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int? ageMonths;
  final String? description;
  final String? imageUrl;
  final bool isUrgent;
  final String adoptionStatus;
  final int adoptionFee;
  final String? sellerId;
  final DateTime createdAt;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.ageMonths,
    this.description,
    this.imageUrl,
    this.isUrgent = false,
    this.adoptionStatus = 'available',
    this.adoptionFee = 150,
    this.sellerId,
    required this.createdAt,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      ageMonths: json['age_months'] as int?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
      adoptionStatus: json['adoption_status'] as String? ?? 'available',
      adoptionFee: json['adoption_fee'] as int? ?? 150,
      sellerId: json['seller_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age_months': ageMonths,
      'description': description,
      'image_url': imageUrl,
      'is_urgent': isUrgent,
      'adoption_status': adoptionStatus,
      'adoption_fee': adoptionFee,
      'seller_id': sellerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
