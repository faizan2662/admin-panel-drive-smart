import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QuizModel> _quizzes = [];
  List<QuizModel> _filteredQuizzes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _categoryFilter = 'All Categories';

  List<QuizModel> get quizzes => _filteredQuizzes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;

  Future<void> loadQuizzes() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .get();

      _quizzes = querySnapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addQuiz(QuizModel quiz) async {
    try {
      await _firestore.collection('quizzes').add(quiz.toMap());
      await loadQuizzes();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateQuiz(String id, QuizModel quiz) async {
    try {
      await _firestore.collection('quizzes').doc(id).update(
        quiz.copyWith(updatedAt: DateTime.now()).toMap(),
      );
      await loadQuizzes();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(String id) async {
    try {
      await _firestore.collection('quizzes').doc(id).delete();
      await loadQuizzes();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleQuizStatus(String id, bool isActive) async {
    try {
      await _firestore.collection('quizzes').doc(id).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await loadQuizzes();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredQuizzes = _quizzes.where((quiz) {
      final matchesSearch = quiz.question
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == 'All Categories' ||
          quiz.category == _categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> getUniqueCategories() {
    final categories = _quizzes
        .where((quiz) => quiz.category != null)
        .map((quiz) => quiz.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
