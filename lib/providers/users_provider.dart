import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UsersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  UserRole? _roleFilter;
  VerificationStatus? _verificationFilter;

  // Getters
  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  UserRole? get roleFilter => _roleFilter;
  VerificationStatus? get verificationFilter => _verificationFilter;

  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore.collection('users')
          .orderBy('timestamp', descending: true)
          .get();

      _users = snapshot.docs.map((doc) {
        try {
          return UserModel.fromFirestore(doc);
        } catch (e) {
          print('Error parsing user document ${doc.id}: $e');
          return null;
        }
      }).where((user) => user != null).cast<UserModel>().toList();

      // Filter out admin users
      _users = _users.where((user) => user.role != UserRole.admin).toList();

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setRoleFilter(UserRole? role) {
    _roleFilter = role;
    _applyFilters();
    notifyListeners();
  }

  void setVerificationFilter(VerificationStatus? status) {
    _verificationFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply role filter
      final matchesRole = _roleFilter == null || user.role == _roleFilter;

      // Apply verification filter
      final matchesVerification = _verificationFilter == null ||
          user.verificationStatus == _verificationFilter;

      return matchesSearch && matchesRole && matchesVerification;
    }).toList();
  }

  Future<void> updateUserVerification(String userId, VerificationStatus status) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updateData = <String, dynamic>{
        'verificationStatus': status.toString().split('.').last,
      };

      if (status == VerificationStatus.verified) {
        updateData['verifiedAt'] = FieldValue.serverTimestamp();
        updateData['verifiedBy'] = 'Admin';
      } else {
        updateData['verifiedAt'] = null;
        updateData['verifiedBy'] = null;
      }

      await _firestore.collection('users').doc(userId).update(updateData);

      // Update local user data
      final userIndex = _users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        final updatedUser = UserModel(
          id: _users[userIndex].id,
          name: _users[userIndex].name,
          email: _users[userIndex].email,
          role: _users[userIndex].role,
          status: _users[userIndex].status,
          verificationStatus: status,
          city: _users[userIndex].city,
          cnic: _users[userIndex].cnic,
          currentLocation: _users[userIndex].currentLocation,
          fatherName: _users[userIndex].fatherName,
          gender: _users[userIndex].gender,
          joinDate: _users[userIndex].joinDate,
          profileImageUrl: _users[userIndex].profileImageUrl,
          metadata: _users[userIndex].metadata,
          verifiedAt: status == VerificationStatus.verified ? DateTime.now() : null,
          verifiedBy: status == VerificationStatus.verified ? 'Admin' : null,
        );
        _users[userIndex] = updatedUser;
      }

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update verification status: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(userId).delete();

      _users.removeWhere((user) => user.id == userId);
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
