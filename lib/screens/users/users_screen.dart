import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/users_provider.dart';
import '../../utils/theme.dart';
import 'user_detail_dialog.dart';
import 'user_edit_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 32,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filters
            Consumer<UsersProvider>(
              builder: (context, usersProvider, _) {
                return Row(
                  children: [
                    // Search
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          usersProvider.setSearchQuery(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Role Filter
                    Expanded(
                      child: DropdownButtonFormField<UserRole?>(
                        value: usersProvider.roleFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem<UserRole?>(
                            value: null,
                            child: Text('All Roles'),
                          ),
                          DropdownMenuItem<UserRole?>(
                            value: UserRole.trainer,
                            child: Text('Trainer'),
                          ),
                          DropdownMenuItem<UserRole?>(
                            value: UserRole.trainee,
                            child: Text('Trainee'),
                          ),
                          DropdownMenuItem<UserRole?>(
                            value: UserRole.organization,
                            child: Text('Organization'),
                          ),
                        ],
                        onChanged: (value) {
                          usersProvider.setRoleFilter(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Verification Status Filter
                    Expanded(
                      child: DropdownButtonFormField<VerificationStatus?>(
                        value: usersProvider.verificationFilter,
                        decoration: InputDecoration(
                          labelText: 'Verification Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem<VerificationStatus?>(
                            value: null,
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem<VerificationStatus?>(
                            value: VerificationStatus.verified,
                            child: Text('Verified'),
                          ),
                          DropdownMenuItem<VerificationStatus?>(
                            value: VerificationStatus.notVerified,
                            child: Text('Not Verified'),
                          ),
                          DropdownMenuItem<VerificationStatus?>(
                            value: VerificationStatus.rejected,
                            child: Text('Rejected'),
                          ),
                        ],
                        onChanged: (value) {
                          usersProvider.setVerificationFilter(value);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Users Table
            Expanded(
              child: Consumer<UsersProvider>(
                builder: (context, usersProvider, child) {
                  if (usersProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (usersProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${usersProvider.error}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => usersProvider.loadUsers(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final users = usersProvider.filteredUsers;

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Role',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Verification',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Join Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  'Actions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table Body
                        Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Name with Avatar
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: user.roleColor,
                                            radius: 20,
                                            child: Text(
                                              user.initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (user.city != null)
                                                  Text(
                                                    user.city!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Email
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        user.email,
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Role
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: user.roleColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          user.roleDisplayName,
                                          style: TextStyle(
                                            color: user.roleColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    // Verification Status
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            user.verificationIcon,
                                            color: user.verificationColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              user.verificationDisplayName,
                                              style: TextStyle(
                                                color: user.verificationColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Join Date
                                    Expanded(
                                      child: Text(
                                        '${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    // Actions
                                    SizedBox(
                                      width: 120,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, size: 18),
                                            onPressed: () => _showUserDetail(context, user),
                                            tooltip: 'View Details',
                                            color: Colors.blue,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            onPressed: () => _showEditUser(context, user),
                                            tooltip: 'Edit User',
                                            color: Colors.orange,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 18),
                                            onPressed: () => _showDeleteConfirmation(context, user),
                                            tooltip: 'Delete User',
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetail(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(user: user),
    );
  }

  void _showEditUser(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserEditDialog(user: user),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<UsersProvider>(context, listen: false)
                  .deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
