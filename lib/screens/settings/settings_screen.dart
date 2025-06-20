import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_model.dart';
import 'admin_create_dialog.dart';
import 'admin_detail_dialog.dart';
import 'change_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadAdmins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 30),

                // Current Admin Info
                _buildCurrentAdminCard(adminProvider),
                const SizedBox(height: 30),

                // Admin Management Section
                _buildAdminManagementSection(adminProvider),

                if (adminProvider.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  _buildErrorCard(adminProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentAdminCard(AdminProvider adminProvider) {
    final currentAdmin = adminProvider.currentAdmin;
    if (currentAdmin == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: currentAdmin.roleColor,
              child: Text(
                currentAdmin.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentAdmin.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentAdmin.email,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: currentAdmin.roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentAdmin.roleDisplayName,
                      style: TextStyle(
                        color: currentAdmin.roleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminManagementSection(AdminProvider adminProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Admin Management',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (adminProvider.canManageAdmins)
                  ElevatedButton.icon(
                    onPressed: () => _showCreateAdminDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Admin'),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            if (adminProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (adminProvider.admins.isEmpty)
              const Center(
                child: Text(
                  'No admins found',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              _buildAdminsList(adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminsList(AdminProvider adminProvider) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminProvider.admins.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final admin = adminProvider.admins[index];
        final isCurrentUser = admin.id == adminProvider.currentAdmin?.id;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: admin.roleColor,
            child: Text(
              admin.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(admin.name),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(admin.email),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: admin.roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      admin.roleDisplayName,
                      style: TextStyle(
                        color: admin.roleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: admin.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      admin.statusDisplayName,
                      style: TextStyle(
                        color: admin.statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleAdminAction(context, admin, action, adminProvider),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 16),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              if (adminProvider.canManageAdmins && !isCurrentUser) ...[
                PopupMenuItem(
                  value: 'password',
                  child: Row(
                    children: [
                      Icon(Icons.lock_reset, size: 16),
                      SizedBox(width: 8),
                      Text('Change Password'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: admin.status == AdminStatus.active ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        admin.status == AdminStatus.active ? Icons.block : Icons.check_circle,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(admin.status == AdminStatus.active ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                if (!admin.isSuperAdmin)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(AdminProvider adminProvider) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                adminProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              onPressed: adminProvider.clearError,
              icon: const Icon(Icons.close, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdminCreateDialog(),
    );
  }

  void _handleAdminAction(
      BuildContext context,
      AdminModel admin,
      String action,
      AdminProvider adminProvider,
      ) {
    switch (action) {
      case 'view':
        showDialog(
          context: context,
          builder: (context) => AdminDetailDialog(admin: admin),
        );
        break;
      case 'password':
        showDialog(
          context: context,
          builder: (context) => ChangePasswordDialog(admin: admin),
        );
        break;
      case 'activate':
        adminProvider.updateAdminStatus(admin.id, AdminStatus.active);
        break;
      case 'deactivate':
        adminProvider.updateAdminStatus(admin.id, AdminStatus.inactive);
        break;
      case 'delete':
        _showDeleteConfirmation(context, admin, adminProvider);
        break;
    }
  }

  void _showDeleteConfirmation(
      BuildContext context,
      AdminModel admin,
      AdminProvider adminProvider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete ${admin.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              adminProvider.deleteAdmin(admin.id);
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
}
