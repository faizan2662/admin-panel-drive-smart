import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AdminRole { superAdmin, admin }
enum AdminStatus { active, inactive }

class AdminModel {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final AdminStatus status;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? profileImageUrl;
  final String createdBy;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLogin,
    this.profileImageUrl,
    required this.createdBy,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle timestamps
    DateTime createdAt;
    if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    DateTime? lastLogin;
    if (data['lastLogin'] != null && data['lastLogin'] is Timestamp) {
      lastLogin = (data['lastLogin'] as Timestamp).toDate();
    }

    // Map role
    AdminRole role = AdminRole.admin;
    if (data['role']?.toString().toLowerCase() == 'superadmin') {
      role = AdminRole.superAdmin;
    }

    // Map status
    AdminStatus status = AdminStatus.active;
    if (data['status']?.toString().toLowerCase() == 'inactive') {
      status = AdminStatus.inactive;
    }

    return AdminModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Admin',
      email: data['email'] ?? '',
      role: role,
      status: status,
      createdAt: createdAt,
      lastLogin: lastLogin,
      profileImageUrl: data['profileImageUrl'],
      createdBy: data['createdBy'] ?? 'System',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'profileImageUrl': profileImageUrl,
      'createdBy': createdBy,
    };
  }

  String get initials {
    return name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join('').toUpperCase();
  }

  Color get roleColor {
    switch (role) {
      case AdminRole.superAdmin:
        return const Color(0xFF7C3AED);
      case AdminRole.admin:
        return const Color(0xFF2563EB);
    }
  }

  Color get statusColor {
    switch (status) {
      case AdminStatus.active:
        return const Color(0xFF16A34A);
      case AdminStatus.inactive:
        return const Color(0xFF6B7280);
    }
  }

  String get roleDisplayName {
    switch (role) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case AdminStatus.active:
        return 'Active';
      case AdminStatus.inactive:
        return 'Inactive';
    }
  }

  bool get isSuperAdmin => role == AdminRole.superAdmin;
}
