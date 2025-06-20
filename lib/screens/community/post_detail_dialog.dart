import 'package:flutter/material.dart';
import '../../models/community_model.dart';
import '../../utils/theme.dart';

class PostDetailDialog extends StatelessWidget {
  final CommunityPostModel post;

  const PostDetailDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Post Details',
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

            // Post Content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: post.profilePic != null
                              ? NetworkImage(post.profilePic!)
                              : null,
                          child: post.profilePic == null
                              ? Text(post.author.isNotEmpty ? post.author[0].toUpperCase() : '?')
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Posted ${post.timeAgo}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (post.role != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.role!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Post Title and Content
                    if (post.title.isNotEmpty) ...[
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Post Stats
                    Row(
                      children: [
                        _buildStatItem(Icons.thumb_up, '${post.likes} likes', Colors.blue),
                        const SizedBox(width: 24),
                        _buildStatItem(Icons.comment, '${post.comments} comments', Colors.green),
                        const SizedBox(width: 24),
                        if (post.isReported)
                          _buildStatItem(Icons.flag, 'Reported', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Post Metadata
                    _buildDetailSection('Post Information', [
                      _buildDetailItem('Post ID', post.id),
                      _buildDetailItem('User ID', post.userId),
                      _buildDetailItem('Created At', _formatDateTime(post.timestamp)),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
