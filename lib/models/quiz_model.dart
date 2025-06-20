import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return QuizModel(
      id: doc.id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correctOptionIndex'] ?? 0,
      category: data['category'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  factory QuizModel.fromMap(Map<String, dynamic> map, String id) {
    return QuizModel(
      id: id,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      category: map['category'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  QuizModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctOptionIndex,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return QuizModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
