import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AdminModel> _admins = [];
  AdminModel? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;

  List<AdminModel> get admins => _admins;
  AdminModel? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canManageAdmins => _currentAdmin?.isSuperAdmin ?? false;

  AdminProvider() {
    _loadCurrentAdmin();
  }

  Future<void> _loadCurrentAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('admins').doc(user.uid).get();
        if (doc.exists) {
          _currentAdmin = AdminModel.fromFirestore(doc);
          notifyListeners();
        }
      } catch (e) {
        _errorMessage = 'Failed to load current admin: $e';
        notifyListeners();
      }
    }
  }

  Future<void> loadAdmins() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .orderBy('createdAt', descending: true)
          .get();

      _admins = snapshot.docs.map((doc) => AdminModel.fromFirestore(doc)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load admins: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createAdmin({
    required String name,
    required String email,
    required String password,
    required AdminRole role,
  }) async {
    if (!canManageAdmins) {
      _errorMessage = 'Only super admins can create new admins';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create Firebase Auth user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin document in Firestore
      final adminData = AdminModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
        status: AdminStatus.active,
        createdAt: DateTime.now(),
        createdBy: _currentAdmin?.name ?? 'System',
      );

      await _firestore
          .collection('admins')
          .doc(userCredential.user!.uid)
          .set(adminData.toFirestore());

      // Reload admins list
      await loadAdmins();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create admin: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAdminStatus(String adminId, AdminStatus status) async {
    if (!canManageAdmins) {
      _errorMessage = 'Only super admins can update admin status';
      notifyListeners();
      return false;
    }

    // Prevent super admin from deactivating themselves
    if (adminId == _currentAdmin?.id && status == AdminStatus.inactive) {
      _errorMessage = 'Cannot deactivate your own account';
      notifyListeners();
      return false;
    }

    try {
      await _firestore.collection('admins').doc(adminId).update({
        'status': status.toString().split('.').last,
      });

      await loadAdmins();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update admin status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeAdminPassword(String adminId, String newPassword) async {
    if (!canManageAdmins) {
      _errorMessage = 'Only super admins can change admin passwords';
      notifyListeners();
      return false;
    }

    try {
      // Note: In a production app, you would need Firebase Admin SDK for this
      // For now, this is a placeholder - the admin would need to reset via email
      _errorMessage = 'Password change functionality requires Firebase Admin SDK';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to change password: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAdmin(String adminId) async {
    if (!canManageAdmins) {
      _errorMessage = 'Only super admins can delete admins';
      notifyListeners();
      return false;
    }

    // Prevent deleting self
    if (adminId == _currentAdmin?.id) {
      _errorMessage = 'Cannot delete your own account';
      notifyListeners();
      return false;
    }

    // Check if target is super admin
    final targetAdmin = _admins.firstWhere((admin) => admin.id == adminId);
    if (targetAdmin.isSuperAdmin) {
      _errorMessage = 'Cannot delete another super admin';
      notifyListeners();
      return false;
    }

    try {
      await _firestore.collection('admins').doc(adminId).delete();
      await loadAdmins();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete admin: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
