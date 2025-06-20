import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load dashboard data only once when screen initializes
    if (!_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
        _hasInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, _) {
          if (dashboardProvider.isLoading && dashboardProvider.stats.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dashboardProvider.errorMessage != null && dashboardProvider.stats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dashboardProvider.errorMessage!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => dashboardProvider.loadDashboardData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = dashboardProvider.stats;

          if (stats.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isMobile),
                SizedBox(height: isMobile ? 16 : 24),

                // Stats Cards
                _buildStatsGrid(stats, isDesktop, isTablet, isMobile),
                SizedBox(height: isMobile ? 16 : 24),

                // Charts
                _buildCharts(stats, dashboardProvider, isDesktop, isMobile),
                SizedBox(height: isMobile ? 16 : 24),

                // Recent Activity
                _buildRecentActivity(dashboardProvider.recentUsers, isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Text(
      'Dashboard Overview',
      style: TextStyle(
        fontSize: isMobile ? 24 : 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats, bool isDesktop, bool isTablet, bool isMobile) {
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);
    // Increased aspect ratio to prevent overflow
    final childAspectRatio = isMobile ? 3.0 : (isTablet ? 2.2 : 1.8);

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Total Users',
          value: stats['totalUsers']?.toString() ?? '0',
          icon: Icons.people,
          color: AppTheme.primaryBlue,
          activeCount: stats['activeUsers'] ?? 0,
          inactiveCount: stats['inactiveUsers'] ?? 0,
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Trainers',
          value: stats['totalTrainers']?.toString() ?? '0',
          icon: Icons.person_pin,
          color: AppTheme.primaryGreen,
          activeCount: stats['activeTrainers'] ?? 0,
          inactiveCount: (stats['totalTrainers'] ?? 0) - (stats['activeTrainers'] ?? 0),
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Trainees',
          value: stats['totalTrainees']?.toString() ?? '0',
          icon: Icons.school,
          color: AppTheme.primaryBlue,
          activeCount: stats['activeTrainees'] ?? 0,
          inactiveCount: (stats['totalTrainees'] ?? 0) - (stats['activeTrainees'] ?? 0),
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Organizations',
          value: stats['totalOrganizations']?.toString() ?? '0',
          icon: Icons.business,
          color: AppTheme.primaryGreen,
          activeCount: stats['activeOrganizations'] ?? 0,
          inactiveCount: (stats['totalOrganizations'] ?? 0) - (stats['activeOrganizations'] ?? 0),
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int activeCount,
    required int inactiveCount,
    required bool isMobile,
  }) {
    final totalCount = activeCount + inactiveCount;
    final activePercentage = totalCount > 0 ? (activeCount / totalCount * 100) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Prevent overflow
            children: [
              // Header row with icon and title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 10),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),

              // Main value
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),

              // Active/Inactive breakdown - more compact
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Active: $activeCount',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Inactive: $inactiveCount',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts(Map<String, dynamic> stats, DashboardProvider provider, bool isDesktop, bool isMobile) {
    return isMobile
        ? Column(
      children: [
        _buildLineChart(provider.userGrowthData, isMobile),
        const SizedBox(height: 16),
        _buildPieChart(stats, isMobile),
      ],
    )
        : Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildLineChart(provider.userGrowthData, isMobile),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPieChart(stats, isMobile),
        ),
      ],
    );
  }

  Widget _buildLineChart(List<FlSpot> growthData, bool isMobile) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'User Growth Trends (Last 12 Months)',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 20 : 24),
              SizedBox(
                height: isMobile ? 220 : 280,
                child: growthData.isNotEmpty
                    ? LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: growthData.map((e) => e.y).reduce((a, b) => a > b ? a : b) / 5,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200]!,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200]!,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          interval: growthData.map((e) => e.y).reduce((a, b) => a > b ? a : b) / 4,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isMobile ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            final now = DateTime.now();
                            final monthIndex = (now.month - 12 + value.toInt()) % 12;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[monthIndex],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isMobile ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: growthData,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: AppTheme.primaryBlue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: AppTheme.primaryBlue,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryBlue.withOpacity(0.4),
                              AppTheme.primaryBlue.withOpacity(0.2),
                              AppTheme.primaryBlue.withOpacity(0.05),
                            ],
                          ),
                        ),
                        shadow: Shadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ),
                    ],
                    minY: 0,
                    maxY: growthData.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1,
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No growth data available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> stats, bool isMobile) {
    final activeUsers = stats['activeUsers'] ?? 0;
    final inactiveUsers = stats['inactiveUsers'] ?? 0;
    final totalUsers = activeUsers + inactiveUsers;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.pie_chart,
                      color: Colors.orange[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'User Status Distribution',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 20 : 24),
              SizedBox(
                height: isMobile ? 220 : 280,
                child: totalUsers > 0
                    ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: isMobile ? 45 : 55,
                          sections: [
                            PieChartSectionData(
                              value: activeUsers.toDouble(),
                              title: '${(activeUsers / totalUsers * 100).toStringAsFixed(0)}%',
                              color: AppTheme.primaryBlue,
                              radius: isMobile ? 65 : 75,
                              titleStyle: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              badgeWidget: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryBlue,
                                  size: 16,
                                ),
                              ),
                              badgePositionPercentageOffset: 1.2,
                            ),
                            PieChartSectionData(
                              value: inactiveUsers.toDouble(),
                              title: '${(inactiveUsers / totalUsers * 100).toStringAsFixed(0)}%',
                              color: Colors.orange[400],
                              radius: isMobile ? 65 : 75,
                              titleStyle: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              badgeWidget: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.pause_circle,
                                  color: Colors.orange[400],
                                  size: 16,
                                ),
                              ),
                              badgePositionPercentageOffset: 1.2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('Active Users', AppTheme.primaryBlue, activeUsers, isMobile),
                          SizedBox(height: isMobile ? 20 : 24),
                          _buildLegendItem('Inactive Users', Colors.orange[400]!, inactiveUsers, isMobile),
                        ],
                      ),
                    ),
                  ],
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No user data available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 12 : 14,
                height: isMobile ? 12 : 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<UserModel> recentUsers, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent User Registrations',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            recentUsers.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentUsers.length,
              itemBuilder: (context, index) {
                final user = recentUsers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: isMobile ? 18 : 22,
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Joined as ${user.role.toString().split('.').last}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(user.joinDate),
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
                : Center(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_disabled,
                      size: isMobile ? 40 : 56,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      'No recent user registrations',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
