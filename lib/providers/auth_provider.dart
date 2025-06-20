import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user exists in admins collection (REQUIRED FOR ADMIN ACCESS)
      final adminDoc = await _firestore.collection('admins').doc(result.user!.uid).get();

      if (!adminDoc.exists) {
        await _auth.signOut();
        _errorMessage = 'Access denied. Admin privileges required.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if admin is active
      final adminData = adminDoc.data() as Map<String, dynamic>;
      if (adminData['status'] != 'active') {
        await _auth.signOut();
        _errorMessage = 'Account is inactive. Please contact super admin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update last login timestamp
      await _firestore.collection('admins').doc(result.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
