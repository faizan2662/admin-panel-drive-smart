import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum SessionType { practical, theory, assessment }
enum SessionStatus { scheduled, inProgress, completed, cancelled }

class SessionModel {
  final String id;
  final String trainerId;
  final String trainerName;
  final String traineeId;
  final String traineeName;
  final SessionType type;
  final SessionStatus status;
  final DateTime scheduledTime;
  final int durationMinutes;
  final String? notes;
  final double? rating;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.traineeId,
    required this.traineeName,
    required this.type,
    required this.status,
    required this.scheduledTime,
    required this.durationMinutes,
    this.notes,
    this.rating,
    required this.createdAt,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      trainerId: data['trainerId'] ?? '',
      trainerName: data['trainerName'] ?? '',
      traineeId: data['traineeId'] ?? '',
      traineeName: data['traineeName'] ?? '',
      type: SessionType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
        orElse: () => SessionType.practical,
      ),
      status: SessionStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 60,
      notes: data['notes'],
      rating: data['rating']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'trainerId': trainerId,
      'trainerName': trainerName,
      'traineeId': traineeId,
      'traineeName': traineeName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'durationMinutes': durationMinutes,
      'notes': notes,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get typeDisplayName {
    switch (type) {
      case SessionType.practical:
        return 'Practical';
      case SessionType.theory:
        return 'Theory';
      case SessionType.assessment:
        return 'Assessment';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case SessionStatus.scheduled:
        return 'Scheduled';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case SessionStatus.scheduled:
        return const Color(0xFF6B7280);
      case SessionStatus.inProgress:
        return const Color(0xFFF59E0B);
      case SessionStatus.completed:
        return const Color(0xFF16A34A);
      case SessionStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  String get timeString {
    return '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
  }
}
