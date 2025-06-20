import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../utils/theme.dart';
import 'post_detail_dialog.dart';
import 'create_post_dialog.dart';
import 'filter_dialog.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).loadPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Community Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter
            Consumer<CommunityProvider>(
              builder: (context, communityProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search posts...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          communityProvider.setSearchQuery(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FilterDialog(
                            currentFilter: communityProvider.roleFilter,
                            onFilterChanged: (filter) {
                              communityProvider.setRoleFilter(filter);
                            },
                            availableFilters: const ['All Posts', 'Trainer', 'Trainee', 'Organization'],
                          ),
                        );
                      },
                      icon: const Icon(Icons.filter_list),
                      label: Text(communityProvider.roleFilter),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Posts List
            Expanded(
              child: Consumer<CommunityProvider>(
                builder: (context, communityProvider, _) {
                  if (communityProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (communityProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading posts',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            communityProvider.errorMessage!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => communityProvider.loadPosts(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (communityProvider.posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            communityProvider.searchQuery.isNotEmpty || communityProvider.roleFilter != 'All Posts'
                                ? 'No posts found matching your filters'
                                : 'No posts found',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          if (communityProvider.searchQuery.isNotEmpty || communityProvider.roleFilter != 'All Posts') ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                communityProvider.setSearchQuery('');
                                communityProvider.setRoleFilter('All Posts');
                              },
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: communityProvider.posts.length,
                    itemBuilder: (context, index) {
                      final post = communityProvider.posts[index];
                      return _buildPostCard(context, post);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
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

                // Post Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (post.role != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRoleColor(post.role!).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.role!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getRoleColor(post.role!),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (post.title.isNotEmpty) ...[
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(post.content),
                      const SizedBox(height: 12),

                      // Post Stats and Actions
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text('${post.likes}'),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(Icons.comment, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${post.comments}'),
                            ],
                          ),
                          const Spacer(),
                          if (post.isReported)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Reported',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            tooltip: 'View Details',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => PostDetailDialog(post: post),
                              );
                            },
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      post.isReported ? Icons.flag_outlined : Icons.flag,
                                      size: 18,
                                      color: post.isReported ? Colors.grey : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(post.isReported ? 'Remove Report Flag' : 'Mark as Reported'),
                                  ],
                                ),
                                onTap: () {
                                  Provider.of<CommunityProvider>(context, listen: false)
                                      .toggleReportStatus(post.id, !post.isReported);
                                },
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete Post'),
                                  ],
                                ),
                                onTap: () {
                                  _showDeleteConfirmation(context, post);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'trainer':
        return Colors.green;
      case 'trainee':
        return Colors.blue;
      case 'organization':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context, post) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<CommunityProvider>(context, listen: false).deletePost(post.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    });
  }
}
