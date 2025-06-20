import 'package:cloud_firestore/cloud_firestore.dart';

enum OrganizationType { drivingSchool, transportation, trainingCenter }

class OrganizationModel {
  final String id;
  final String name;
  final OrganizationType type;
  final String location;
  final int trainersCount;
  final int traineesCount;
  final double rating;
  final bool isActive;
  final DateTime createdAt;
  final String? logoUrl;
  final Map<String, dynamic>? metadata;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.trainersCount,
    required this.traineesCount,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    this.logoUrl,
    this.metadata,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: OrganizationType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
        orElse: () => OrganizationType.drivingSchool,
      ),
      location: data['location'] ?? '',
      trainersCount: data['trainersCount'] ?? 0,
      traineesCount: data['traineesCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      logoUrl: data['logoUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'location': location,
      'trainersCount': trainersCount,
      'traineesCount': traineesCount,
      'rating': rating,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'logoUrl': logoUrl,
      'metadata': metadata,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case OrganizationType.drivingSchool:
        return 'Driving School';
      case OrganizationType.transportation:
        return 'Transportation';
      case OrganizationType.trainingCenter:
        return 'Training Center';
    }
  }
}
