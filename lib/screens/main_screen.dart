import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/theme.dart';
import '../widgets/logo_widget.dart';
import 'dashboard/dashboard_screen.dart';
import 'users/users_screen.dart';
import 'organizations/organizations_screen.dart';
import 'training/training_screen.dart';
import 'sessions/sessions_screen.dart';
import 'community/community_screen.dart';
import 'quizzes/quizzes_screen.dart';
import 'analytics/analytics_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const UsersScreen(),
    const OrganizationsScreen(),
    const TrainingScreen(),
    const SessionsScreen(),
    const CommunityScreen(),
    const QuizzesScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
    NavigationItem(icon: Icons.people, label: 'Users'),
    NavigationItem(icon: Icons.business, label: 'Organizations'),
    NavigationItem(icon: Icons.school, label: 'Training'),
    NavigationItem(icon: Icons.calendar_today, label: 'Sessions'),
    NavigationItem(icon: Icons.forum, label: 'Community'),
    NavigationItem(icon: Icons.quiz, label: 'Quizzes'),
    NavigationItem(icon: Icons.analytics, label: 'Analytics'),
    NavigationItem(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize dashboard data when main screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 255,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Column(
              children: [
                // Header with Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const LogoIconWidget(size: 180),
                ),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _selectedIndex == index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                            size: 20,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: AppTheme.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });

                            // Reload dashboard data when dashboard is selected
                            if (index == 0) {
                              Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // User Profile
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue,
                          child: Text(
                            authProvider.user?.email?.substring(0, 1).toUpperCase() ?? 'A',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          authProvider.user?.email ?? 'Admin',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: const Text('Administrator', style: TextStyle(fontSize: 12)),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.logout, size: 18),
                                  SizedBox(width: 8),
                                  Text('Sign Out'),
                                ],
                              ),
                              onTap: () => authProvider.signOut(),
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

          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
