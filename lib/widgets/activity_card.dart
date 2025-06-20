import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

class ActivityCard extends StatelessWidget {
  final List<UserModel> recentUsers;

  const ActivityCard({
    super.key,
    required this.recentUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline, // Changed from Icons.activity_zone to Icons.timeline
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentUsers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No recent activities',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...recentUsers.map((user) => _buildActivityItem(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: user.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: user.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' joined as ${user.roleDisplayName.toLowerCase()}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTimeAgo(user.joinDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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
