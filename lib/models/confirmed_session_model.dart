import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmedSessionModel {
  final String id;
  final DateTime acceptedAt;
  final String bookingId;
  final String requestType;
  final List<String> selectedPlans;
  final List<SessionDetail> sessions;

  ConfirmedSessionModel({
    required this.id,
    required this.acceptedAt,
    required this.bookingId,
    required this.requestType,
    required this.selectedPlans,
    required this.sessions,
  });

  factory ConfirmedSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return ConfirmedSessionModel(
      id: id,
      acceptedAt: _parseTimestamp(map['acceptedAt']),
      bookingId: map['bookingId'] ?? '',
      requestType: map['requestType'] ?? '',
      selectedPlans: List<String>.from(map['selectedPlans'] ?? []),
      sessions: (map['sessions'] as List<dynamic>?)
          ?.map((session) => SessionDetail.fromMap(session))
          .toList() ??
          [],
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'acceptedAt': Timestamp.fromDate(acceptedAt),
      'bookingId': bookingId,
      'requestType': requestType,
      'selectedPlans': selectedPlans,
      'sessions': sessions.map((session) => session.toMap()).toList(),
    };
  }
}

class SessionDetail {
  final DateTime createdAt;
  final String date;
  final int dateTime;
  final bool isBooked;
  final String time;
  final String? status;
  final int? totalAmount;
  final String? traineeId;
  final String? traineeName;
  final String? trainerId;
  final String? trainerName;

  SessionDetail({
    required this.createdAt,
    required this.date,
    required this.dateTime,
    required this.isBooked,
    required this.time,
    this.status,
    this.totalAmount,
    this.traineeId,
    this.traineeName,
    this.trainerId,
    this.trainerName,
  });

  factory SessionDetail.fromMap(Map<String, dynamic> map) {
    return SessionDetail(
      createdAt: _parseTimestamp(map['createdAt']),
      date: map['date'] ?? '',
      dateTime: map['dateTime'] ?? 0,
      isBooked: map['isBooked'] ?? false,
      time: map['time'] ?? '',
      status: map['status'],
      totalAmount: map['totalAmount'],
      traineeId: map['traineeId'],
      traineeName: map['traineeName'],
      trainerId: map['trainerId'],
      trainerName: map['trainerName'],
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'date': date,
      'dateTime': dateTime,
      'isBooked': isBooked,
      'time': time,
      'status': status,
      'totalAmount': totalAmount,
      'traineeId': traineeId,
      'traineeName': traineeName,
      'trainerId': trainerId,
      'trainerName': trainerName,
    };
  }
}
