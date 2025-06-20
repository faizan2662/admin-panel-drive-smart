import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_model.dart';

class CommunityProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CommunityPostModel> _posts = [];
  List<CommunityPostModel> _filteredPosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _roleFilter = 'All Posts';

  List<CommunityPostModel> get posts => _filteredPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get roleFilter => _roleFilter;

  Future<void> loadPosts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Loading posts from Firestore...');

      // Try different query approaches to handle potential security rule issues
      QuerySnapshot snapshot;
      try {
        // First try with orderBy
        snapshot = await _firestore.collection('posts').orderBy('timestamp', descending: true).get();
      } catch (e) {
        print('OrderBy query failed, trying simple get: $e');
        // If orderBy fails due to security rules, try simple get
        snapshot = await _firestore.collection('posts').get();
      }

      print('Found ${snapshot.docs.length} posts in Firestore');

      _posts = [];
      for (var doc in snapshot.docs) {
        try {
          print('Processing post: ${doc.id}');
          final data = doc.data() as Map<String, dynamic>;
          print('Post data: $data');

          // Check if required fields exist
          if (data['author'] == null || data['content'] == null) {
            print('Skipping post ${doc.id} - missing required fields');
            continue;
          }

          final post = CommunityPostModel.fromFirestore(doc);
          _posts.add(post);
          print('Successfully added post: ${post.title} by ${post.author}');
        } catch (e) {
          print('Error parsing post document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          // Continue processing other posts even if one fails
          continue;
        }
      }

      print('Successfully parsed ${_posts.length} posts');

      // Sort posts by timestamp if not already sorted
      _posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading posts: $e');
      _errorMessage = 'Error loading posts: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setRoleFilter(String role) {
    _roleFilter = role;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPosts = _posts.where((post) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.author.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply role filter
      bool matchesRole = true;
      if (_roleFilter != 'All Posts') {
        final postRole = post.role?.toLowerCase() ?? '';
        final filterRole = _roleFilter.toLowerCase();

        // Handle different role name variations
        if (filterRole == 'organization' && (postRole == 'organisation' || postRole == 'organization')) {
          matchesRole = true;
        } else {
          matchesRole = postRole == filterRole;
        }
      }

      return matchesSearch && matchesRole;
    }).toList();

    print('Applied filters - Search: "$_searchQuery", Role: "$_roleFilter"');
    print('Filtered posts: ${_filteredPosts.length} out of ${_posts.length}');
    for (var post in _filteredPosts) {
      print('- ${post.title} by ${post.author} (${post.role})');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('posts').doc(postId).delete();

      _posts.removeWhere((post) => post.id == postId);
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete post: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleReportStatus(String postId, bool isReported) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'isReported': isReported,
      });

      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final updatedPost = CommunityPostModel(
          id: _posts[index].id,
          userId: _posts[index].userId,
          author: _posts[index].author,
          content: _posts[index].content,
          title: _posts[index].title,
          likes: _posts[index].likes,
          comments: _posts[index].comments,
          timestamp: _posts[index].timestamp,
          isReported: isReported,
          profilePic: _posts[index].profilePic,
          role: _posts[index].role,
        );

        _posts[index] = updatedPost;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update post: ${e.toString()}';
      notifyListeners();
    }
  }
}
