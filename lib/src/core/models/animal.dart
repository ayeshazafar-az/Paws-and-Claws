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
  final String? sellerName;
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
    this.sellerName,
    required this.createdAt,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    final rawDesc = json['description'] as String? ?? '';
    String? sName;
    String cleanDesc = rawDesc;
    if (rawDesc.contains('[SELLER:')) {
      final split = rawDesc.split('[SELLER:');
      cleanDesc = split[0].trim();
      sName = split[1].replaceAll(']', '').trim();
    }

    return Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      ageMonths: json['age_months'] as int?,
      description: cleanDesc,
      imageUrl: json['image_url'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
      adoptionStatus: json['adoption_status'] as String? ?? 'available',
      adoptionFee: json['adoption_fee'] as int? ?? 150,
      sellerId: json['seller_id'] as String?,
      sellerName: sName,
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
