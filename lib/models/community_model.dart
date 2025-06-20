import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPostModel {
  final String id;
  final String userId;
  final String author;
  final String content;
  final String title;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final bool isReported;
  final String? profilePic;
  final String? role;

  CommunityPostModel({
    required this.id,
    required this.userId,
    required this.author,
    required this.content,
    required this.title,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isReported = false,
    this.profilePic,
    this.role,
  });

  factory CommunityPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle timestamp with null safety
    DateTime postTimestamp;
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        postTimestamp = (data['timestamp'] as Timestamp).toDate();
      } else {
        postTimestamp = DateTime.now();
      }
    } else {
      postTimestamp = DateTime.now();
    }

    return CommunityPostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      author: data['author'] ?? 'Unknown User',
      content: data['content'] ?? '',
      title: data['title'] ?? '',
      likes: (data['likes'] is int) ? data['likes'] : 0,
      comments: (data['comments'] is int) ? data['comments'] : 0,
      timestamp: postTimestamp,
      isReported: data['isReported'] ?? false,
      profilePic: data['profilePic'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'author': author,
      'content': content,
      'title': title,
      'likes': likes,
      'comments': comments,
      'timestamp': Timestamp.fromDate(timestamp),
      'isReported': isReported,
      'profilePic': profilePic,
      'role': role,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
