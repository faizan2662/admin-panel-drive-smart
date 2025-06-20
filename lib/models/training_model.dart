import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TrainingLevel { beginner, intermediate, advanced, professional }

class TrainingModel {
  final String id;
  final String title;
  final String description;
  final TrainingLevel level;
  final int durationWeeks;
  final int studentsCount;
  final double progressPercentage;
  final bool isActive;
  final DateTime createdAt;
  final String? imageUrl;
  final List<String> topics;

  TrainingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.durationWeeks,
    required this.studentsCount,
    required this.progressPercentage,
    required this.isActive,
    required this.createdAt,
    this.imageUrl,
    required this.topics,
  });

  factory TrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      level: TrainingLevel.values.firstWhere(
            (e) => e.toString().split('.').last == data['level'],
        orElse: () => TrainingLevel.beginner,
      ),
      durationWeeks: data['durationWeeks'] ?? 0,
      studentsCount: data['studentsCount'] ?? 0,
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      topics: List<String>.from(data['topics'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'level': level.toString().split('.').last,
      'durationWeeks': durationWeeks,
      'studentsCount': studentsCount,
      'progressPercentage': progressPercentage,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'topics': topics,
    };
  }

  String get levelDisplayName {
    switch (level) {
      case TrainingLevel.beginner:
        return 'Beginner';
      case TrainingLevel.intermediate:
        return 'Intermediate';
      case TrainingLevel.advanced:
        return 'Advanced';
      case TrainingLevel.professional:
        return 'Professional';
    }
  }

  Color get levelColor {
    switch (level) {
      case TrainingLevel.beginner:
        return const Color(0xFF16A34A);
      case TrainingLevel.intermediate:
        return const Color(0xFF2563EB);
      case TrainingLevel.advanced:
        return const Color(0xFFF59E0B);
      case TrainingLevel.professional:
        return const Color(0xFFDC2626);
    }
  }

  String get durationText {
    return '$durationWeeks week${durationWeeks > 1 ? 's' : ''}';
  }
}
