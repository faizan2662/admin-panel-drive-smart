import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/user_model.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dashboard data
  Map<String, dynamic> _stats = {};
  List<UserModel> _recentUsers = [];
  List<FlSpot> _userGrowthData = [];
  List<double> _trainerGrowthData = [];
  List<double> _traineeGrowthData = [];
  List<double> _organizationGrowthData = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;
  bool _hasLoadedOnce = false;

  // Getters
  Map<String, dynamic> get stats => _stats;
  List<UserModel> get recentUsers => _recentUsers;
  List<FlSpot> get userGrowthData => _userGrowthData;
  List<double> getTrainerGrowthData() => _trainerGrowthData;
  List<double> getTraineeGrowthData() => _traineeGrowthData;
  List<double> getOrganizationGrowthData() => _organizationGrowthData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardProvider() {
    // Load data immediately when provider is created
    loadDashboardData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadDashboardData() async {
    if (_hasLoadedOnce && _isLoading) return; // Prevent multiple simultaneous loads

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load all data in parallel
      await Future.wait([
        _loadOverallStats(),
        _loadRecentUsers(),
        _loadUserGrowthData(),
        _loadRoleSpecificGrowthData(),
      ]);

      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();

      // Set up auto-refresh only after first successful load
      if (_refreshTimer == null) {
        _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
          _refreshData();
        });
      }
    } catch (e) {
      _errorMessage = 'Error loading dashboard data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Dashboard error: $_errorMessage');
    }
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;

    try {
      await Future.wait([
        _loadOverallStats(),
        _loadRecentUsers(),
        _loadUserGrowthData(),
        _loadRoleSpecificGrowthData(),
      ]);
      notifyListeners();
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  Future<void> _loadOverallStats() async {
    try {
      // Initialize stats with zeros
      _stats = {
        'totalUsers': 0,
        'totalTrainers': 0,
        'totalTrainees': 0,
        'totalOrganizations': 0,
        'totalQuizzes': 0,
        'activeQuizzes': 0,
      };

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      final users = usersSnapshot.docs;

      _stats['totalUsers'] = users.length;

      // Count roles
      int totalTrainers = 0;
      int totalTrainees = 0;
      int totalOrganizations = 0;

      for (var doc in users) {
        final data = doc.data();

        // Check different possible role field names and normalize role values
        final role = _normalizeRole(data['role'] ?? data['userType'] ?? data['type'] ?? '');

        // Count by role
        switch (role.toLowerCase()) {
          case 'trainer':
          case 'instructor':
          case 'teacher':
            totalTrainers++;
            break;
          case 'trainee':
          case 'student':
          case 'learner':
            totalTrainees++;
            break;
          case 'organization':
          case 'org':
          case 'company':
          case 'institution':
            totalOrganizations++;
            break;
          case 'admin':
          case 'administrator':
          // Count admins as active users but don't include in role-specific counts
            break;
          default:
          // If no specific role, count as trainee by default
            totalTrainees++;
            break;
        }
      }

      _stats['totalTrainers'] = totalTrainers;
      _stats['totalTrainees'] = totalTrainees;
      _stats['totalOrganizations'] = totalOrganizations;

      print('=== FINAL STATS ===');
      print('Total Users: ${_stats['totalUsers']}');
      print('Total Trainers: $totalTrainers');
      print('Total Trainees: $totalTrainees');
      print('Total Organizations: $totalOrganizations');
      print('=== END STATS ===');

      // Get quizzes count
      try {
        final quizzesSnapshot = await _firestore.collection('quizzes').get();
        _stats['totalQuizzes'] = quizzesSnapshot.docs.length;

        // Count active quizzes
        int activeQuizzes = 0;
        for (var doc in quizzesSnapshot.docs) {
          final data = doc.data();
          if (data['isActive'] == true || data['active'] == true || data['status'] == 'active') {
            activeQuizzes++;
          }
        }
        _stats['activeQuizzes'] = activeQuizzes;
      } catch (e) {
        print('Error loading quizzes: $e');
      }

    } catch (e) {
      print('Error loading stats: $e');
      throw Exception('Failed to load statistics: $e');
    }
  }

  // Helper method to normalize role values
  String _normalizeRole(dynamic role) {
    if (role == null) return '';

    final roleStr = role.toString().toLowerCase().trim();

    // Map various role variations to standard roles
    switch (roleStr) {
      case 'trainer':
      case 'instructor':
      case 'teacher':
      case 'coach':
        return 'trainer';
      case 'trainee':
      case 'student':
      case 'learner':
      case 'pupil':
        return 'trainee';
      case 'organization':
      case 'org':
      case 'company':
      case 'institution':
      case 'school':
        return 'organization';
      case 'admin':
      case 'administrator':
      case 'superuser':
        return 'admin';
      default:
        return roleStr;
    }
  }

  Future<void> _loadRecentUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('timestamp', descending: true)
          .limit(8)
          .get();

      _recentUsers = [];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final role = _normalizeRole(data['role'] ?? data['userType'] ?? data['type'] ?? '');

          _recentUsers.add(
            UserModel(
              id: doc.id,
              name: data['name'] ?? 'Unknown',
              email: data['email'] ?? 'No email',
              role: _parseUserRole(role),
              status: UserStatus.active, // Default status
              joinDate: data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now(),
            ),
          );
        } catch (e) {
          print('Error parsing user: $e');
        }
      }
    } catch (e) {
      print('Error loading recent users: $e');
      _recentUsers = [];
    }
  }

  Future<void> _loadUserGrowthData() async {
    try {
      _userGrowthData = [];

      // Get data for the last 12 months
      final now = DateTime.now();
      final List<DateTime> monthStarts = [];

      for (int i = 11; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        monthStarts.add(monthStart);
      }

      for (int i = 0; i < monthStarts.length; i++) {
        final monthStart = monthStarts[i];
        final monthEnd = i < monthStarts.length - 1
            ? monthStarts[i + 1]
            : DateTime(now.year, now.month + 1, 1);

        try {
          final snapshot = await _firestore
              .collection('users')
              .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
              .where('timestamp', isLessThan: Timestamp.fromDate(monthEnd))
              .get();

          _userGrowthData.add(FlSpot(i.toDouble(), snapshot.docs.length.toDouble()));
        } catch (e) {
          _userGrowthData.add(FlSpot(i.toDouble(), 0));
        }
      }
    } catch (e) {
      print('Error loading user growth data: $e');
      _userGrowthData = [];
    }
  }

  Future<void> _loadRoleSpecificGrowthData() async {
    try {
      _trainerGrowthData = [];
      _traineeGrowthData = [];
      _organizationGrowthData = [];

      // Get data for the last 12 months
      final now = DateTime.now();
      final List<DateTime> monthStarts = [];

      for (int i = 11; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        monthStarts.add(monthStart);
      }

      for (int i = 0; i < monthStarts.length; i++) {
        final monthStart = monthStarts[i];
        final monthEnd = i < monthStarts.length - 1
            ? monthStarts[i + 1]
            : DateTime(now.year, now.month + 1, 1);

        try {
          final snapshot = await _firestore
              .collection('users')
              .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
              .where('timestamp', isLessThan: Timestamp.fromDate(monthEnd))
              .get();

          int trainers = 0;
          int trainees = 0;
          int organizations = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final role = _normalizeRole(data['role'] ?? data['userType'] ?? data['type'] ?? '');

            switch (role.toLowerCase()) {
              case 'trainer':
              case 'instructor':
              case 'teacher':
                trainers++;
                break;
              case 'trainee':
              case 'student':
              case 'learner':
                trainees++;
                break;
              case 'organization':
              case 'org':
              case 'company':
              case 'institution':
                organizations++;
                break;
              default:
                trainees++; // Default to trainee
                break;
            }
          }

          _trainerGrowthData.add(trainers.toDouble());
          _traineeGrowthData.add(trainees.toDouble());
          _organizationGrowthData.add(organizations.toDouble());

        } catch (e) {
          _trainerGrowthData.add(0);
          _traineeGrowthData.add(0);
          _organizationGrowthData.add(0);
        }
      }

      print('=== GROWTH DATA ===');
      print('Trainer Growth: $_trainerGrowthData');
      print('Trainee Growth: $_traineeGrowthData');
      print('Organization Growth: $_organizationGrowthData');
      print('=== END GROWTH DATA ===');

    } catch (e) {
      print('Error loading role-specific growth data: $e');
      _trainerGrowthData = List.filled(12, 0);
      _traineeGrowthData = List.filled(12, 0);
      _organizationGrowthData = List.filled(12, 0);
    }
  }

  UserRole _parseUserRole(String? role) {
    final normalizedRole = _normalizeRole(role);
    switch (normalizedRole) {
      case 'admin': return UserRole.admin;
      case 'trainer': return UserRole.trainer;
      case 'trainee': return UserRole.trainee;
      case 'organization': return UserRole.organization;
      default: return UserRole.trainee;
    }
  }
}
