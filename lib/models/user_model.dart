import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserRole { admin, trainer, trainee, organization }
enum UserStatus { active, inactive, pending }
enum VerificationStatus { notVerified, verified, rejected }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final UserStatus status;
  final VerificationStatus verificationStatus;
  final String? city;
  final String? cnic;
  final String? currentLocation;
  final String? fatherName;
  final String? gender;
  final DateTime joinDate;
  final String? profileImageUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.verificationStatus = VerificationStatus.notVerified,
    this.city,
    this.cnic,
    this.currentLocation,
    this.fatherName,
    this.gender,
    required this.joinDate,
    this.profileImageUrl,
    this.metadata,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle timestamp with null safety
    DateTime joinDate;
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        joinDate = (data['timestamp'] as Timestamp).toDate();
      } else {
        joinDate = DateTime.now();
      }
    } else {
      joinDate = DateTime.now();
    }

    // Handle verification timestamp
    DateTime? verifiedAt;
    if (data['verifiedAt'] != null && data['verifiedAt'] is Timestamp) {
      verifiedAt = (data['verifiedAt'] as Timestamp).toDate();
    }

    // Map userType to UserRole
    UserRole role;
    String userType = data['userType']?.toString().toLowerCase() ?? 'trainee';
    switch (userType) {
      case 'trainer':
        role = UserRole.trainer;
        break;
      case 'trainee':
        role = UserRole.trainee;
        break;
      case 'organization':
        role = UserRole.organization;
        break;
      case 'admin':
        role = UserRole.admin;
        break;
      default:
        role = UserRole.trainee;
    }

    // Map verification status
    VerificationStatus verificationStatus;
    String verificationStr = data['verificationStatus']?.toString().toLowerCase() ?? 'notverified';
    switch (verificationStr) {
      case 'verified':
        verificationStatus = VerificationStatus.verified;
        break;
      case 'rejected':
        verificationStatus = VerificationStatus.rejected;
        break;
      default:
        verificationStatus = VerificationStatus.notVerified;
    }

    return UserModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown User',
      email: data['email'] ?? '',
      role: role,
      status: UserStatus.active, // Default to active since your data doesn't have status
      verificationStatus: verificationStatus,
      city: data['city'],
      cnic: data['cnic'],
      currentLocation: data['currentLocation'],
      fatherName: data['fatherName'],
      gender: data['gender'],
      joinDate: joinDate,
      profileImageUrl: data['profileImageUrl'],
      metadata: data,
      verifiedAt: verifiedAt,
      verifiedBy: data['verifiedBy'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    // Handle timestamp with null safety
    DateTime joinDate;
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        joinDate = (data['timestamp'] as Timestamp).toDate();
      } else {
        joinDate = DateTime.now();
      }
    } else if (data['joinDate'] != null) {
      if (data['joinDate'] is Timestamp) {
        joinDate = (data['joinDate'] as Timestamp).toDate();
      } else {
        joinDate = DateTime.now();
      }
    } else {
      joinDate = DateTime.now();
    }

    // Handle verification timestamp
    DateTime? verifiedAt;
    if (data['verifiedAt'] != null && data['verifiedAt'] is Timestamp) {
      verifiedAt = (data['verifiedAt'] as Timestamp).toDate();
    }

    // Map userType to UserRole
    UserRole role;
    String userType = data['userType']?.toString().toLowerCase() ?? 'trainee';
    switch (userType) {
      case 'trainer':
        role = UserRole.trainer;
        break;
      case 'trainee':
        role = UserRole.trainee;
        break;
      case 'organization':
        role = UserRole.organization;
        break;
      case 'admin':
        role = UserRole.admin;
        break;
      default:
        role = UserRole.trainee;
    }

    // Map verification status
    VerificationStatus verificationStatus;
    String verificationStr = data['verificationStatus']?.toString().toLowerCase() ?? 'notverified';
    switch (verificationStr) {
      case 'verified':
        verificationStatus = VerificationStatus.verified;
        break;
      case 'rejected':
        verificationStatus = VerificationStatus.rejected;
        break;
      default:
        verificationStatus = VerificationStatus.notVerified;
    }

    return UserModel(
      id: id,
      name: data['name'] ?? 'Unknown User',
      email: data['email'] ?? '',
      role: role,
      status: UserStatus.active,
      verificationStatus: verificationStatus,
      city: data['city'],
      cnic: data['cnic'],
      currentLocation: data['currentLocation'],
      fatherName: data['fatherName'],
      gender: data['gender'],
      joinDate: joinDate,
      profileImageUrl: data['profileImageUrl'],
      metadata: data,
      verifiedAt: verifiedAt,
      verifiedBy: data['verifiedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userType': role.toString().split('.').last,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'city': city,
      'cnic': cnic,
      'currentLocation': currentLocation,
      'fatherName': fatherName,
      'gender': gender,
      'timestamp': Timestamp.fromDate(joinDate),
      'joinDate': Timestamp.fromDate(joinDate),
      'profileImageUrl': profileImageUrl,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
    };
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  String get initials {
    return name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join('').toUpperCase();
  }

  Color get roleColor {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF7C3AED);
      case UserRole.trainer:
        return const Color(0xFF16A34A);
      case UserRole.trainee:
        return const Color(0xFF2563EB);
      case UserRole.organization:
        return const Color(0xFFF59E0B);
    }
  }

  Color get statusColor {
    switch (status) {
      case UserStatus.active:
        return const Color(0xFF16A34A);
      case UserStatus.inactive:
        return const Color(0xFF6B7280);
      case UserStatus.pending:
        return const Color(0xFFF59E0B);
    }
  }

  Color get verificationColor {
    switch (verificationStatus) {
      case VerificationStatus.verified:
        return const Color(0xFF16A34A);
      case VerificationStatus.notVerified:
        return const Color(0xFFF59E0B);
      case VerificationStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.trainee:
        return 'Trainee';
      case UserRole.organization:
        return 'Organization';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.pending:
        return 'Pending';
    }
  }

  String get verificationDisplayName {
    switch (verificationStatus) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.notVerified:
        return 'Not Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  IconData get verificationIcon {
    switch (verificationStatus) {
      case VerificationStatus.verified:
        return Icons.verified;
      case VerificationStatus.notVerified:
        return Icons.pending;
      case VerificationStatus.rejected:
        return Icons.cancel;
    }
  }

  String get organizationId => '';
  String get organizationName => city ?? '';
}
