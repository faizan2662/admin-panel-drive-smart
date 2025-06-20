import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../utils/theme.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Create New Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),

                      // Content
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter post content';
                          }
                          return null;
                        },
                      ),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[600], fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Create Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('You must be logged in to create a post');
      }

      final postData = {
        'userId': authProvider.user!.uid,
        'author': authProvider.user!.email ?? 'Anonymous',
        'title': _titleController.text,
        'content': _contentController.text,
        'likes': 0,
        'comments': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'isReported': false,
        'role': 'admin', // Since this is created from admin panel
      };

      await firestore.collection('posts').add(postData);

      // Refresh posts list
      if (!mounted) return;
      Provider.of<CommunityProvider>(context, listen: false).loadPosts();

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating post: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
