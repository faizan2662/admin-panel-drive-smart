import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final DateTime? acceptedAt;
  final String bookedBy;
  final int completedLessons;
  final DateTime createdAt;
  final String location;
  final List<OfferedSession> offeredSessions;
  final DateTime? paymentDate;
  final String? paymentStatus;
  final int progressPercent;
  final String requestType;
  final List<String> selectedPlans;
  final int sessionCount;
  final String status;
  final DateTime timestamp;
  final int totalAmount;
  final int totalLessons;
  final String? traineeId;
  final String? traineeName;
  final String? traineeProfilePic;
  final String? trainerId;
  final String? trainerLocation;
  final String? trainerName;
  final String? trainerProfilePic;

  BookingModel({
    required this.id,
    this.acceptedAt,
    required this.bookedBy,
    required this.completedLessons,
    required this.createdAt,
    required this.location,
    required this.offeredSessions,
    this.paymentDate,
    this.paymentStatus,
    required this.progressPercent,
    required this.requestType,
    required this.selectedPlans,
    required this.sessionCount,
    required this.status,
    required this.timestamp,
    required this.totalAmount,
    required this.totalLessons,
    this.traineeId,
    this.traineeName,
    this.traineeProfilePic,
    this.trainerId,
    this.trainerLocation,
    this.trainerName,
    this.trainerProfilePic,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      acceptedAt: _parseTimestamp(map['acceptedAt']),
      bookedBy: map['bookedBy'] ?? '',
      completedLessons: _parseIntValue(map['completedLessons']),
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      location: map['location'] ?? '',
      offeredSessions: (map['offeredSessions'] as List<dynamic>?)
          ?.map((session) => OfferedSession.fromMap(session))
          .toList() ??
          [],
      paymentDate: _parseTimestamp(map['paymentDate']),
      paymentStatus: map['paymentStatus'],
      progressPercent: _parseIntValue(map['progressPercent']),
      requestType: map['requestType'] ?? '',
      selectedPlans: _parseStringList(map['selectedPlans']),
      sessionCount: _parseIntValue(map['sessionCount']),
      status: map['status'] ?? 'booking',
      timestamp: _parseTimestamp(map['timestamp']) ?? DateTime.now(),
      totalAmount: _parseIntValue(map['totalAmount']),
      totalLessons: _parseIntValue(map['totalLessons']),
      traineeId: map['traineeId'],
      traineeName: map['traineeName'],
      traineeProfilePic: map['traineeProfilePic'],
      trainerId: map['trainerId'],
      trainerLocation: map['trainerLocation'],
      trainerName: map['trainerName'],
      trainerProfilePic: map['trainerProfilePic'],
    );
  }

  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'bookedBy': bookedBy,
      'completedLessons': completedLessons,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location,
      'offeredSessions': offeredSessions.map((session) => session.toMap()).toList(),
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'paymentStatus': paymentStatus,
      'progressPercent': progressPercent,
      'requestType': requestType,
      'selectedPlans': selectedPlans,
      'sessionCount': sessionCount,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'totalAmount': totalAmount,
      'totalLessons': totalLessons,
      'traineeId': traineeId,
      'traineeName': traineeName,
      'traineeProfilePic': traineeProfilePic,
      'trainerId': trainerId,
      'trainerLocation': trainerLocation,
      'trainerName': trainerName,
      'trainerProfilePic': trainerProfilePic,
    };
  }
}

class OfferedSession {
  final DateTime createdAt;
  final String date;
  final int dateTime;
  final bool isBooked;
  final String time;

  OfferedSession({
    required this.createdAt,
    required this.date,
    required this.dateTime,
    required this.isBooked,
    required this.time,
  });

  factory OfferedSession.fromMap(Map<String, dynamic> map) {
    return OfferedSession(
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      date: map['date'] ?? '',
      dateTime: map['dateTime'] ?? 0,
      isBooked: map['isBooked'] ?? false,
      time: map['time'] ?? '',
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is String) return DateTime.tryParse(timestamp) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'date': date,
      'dateTime': dateTime,
      'isBooked': isBooked,
      'time': time,
    };
  }
}
