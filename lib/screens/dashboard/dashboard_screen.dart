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
    final crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);
    final childAspectRatio = isMobile ? 1.4 : (isTablet ? 1.8 : 1.5);

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
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
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Trainers',
          value: stats['totalTrainers']?.toString() ?? '0',
          icon: Icons.person_pin,
          color: AppTheme.primaryGreen,
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Trainees',
          value: stats['totalTrainees']?.toString() ?? '0',
          icon: Icons.school,
          color: Colors.orange[600]!,
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Organizations',
          value: stats['totalOrganizations']?.toString() ?? '0',
          icon: Icons.business,
          color: Colors.purple[600]!,
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
    required bool isMobile,
  }) {
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
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header row with icon and title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Main value
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
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
    final totalTrainers = stats['totalTrainers'] ?? 0;
    final totalTrainees = stats['totalTrainees'] ?? 0;
    final totalOrganizations = stats['totalOrganizations'] ?? 0;
    final totalUsers = totalTrainers + totalTrainees + totalOrganizations;

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
                      'User Distribution',
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
                    ? isMobile
                    ? Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 35,
                          sections: _getPieChartSections(totalTrainers, totalTrainees, totalOrganizations, totalUsers, true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (totalTrainers > 0)
                              _buildLegendItem('Trainers', AppTheme.primaryGreen, totalTrainers, isMobile),
                            if (totalTrainers > 0 && (totalTrainees > 0 || totalOrganizations > 0))
                              const SizedBox(height: 8),
                            if (totalTrainees > 0)
                              _buildLegendItem('Trainees', Colors.orange[600]!, totalTrainees, isMobile),
                            if (totalTrainees > 0 && totalOrganizations > 0)
                              const SizedBox(height: 8),
                            if (totalOrganizations > 0)
                              _buildLegendItem('Organizations', Colors.purple[600]!, totalOrganizations, isMobile),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 55,
                          sections: _getPieChartSections(totalTrainers, totalTrainees, totalOrganizations, totalUsers, false),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (totalTrainers > 0) ...[
                              _buildLegendItem('Trainers', AppTheme.primaryGreen, totalTrainers, isMobile),
                              const SizedBox(height: 16),
                            ],
                            if (totalTrainees > 0) ...[
                              _buildLegendItem('Trainees', Colors.orange[600]!, totalTrainees, isMobile),
                              const SizedBox(height: 16),
                            ],
                            if (totalOrganizations > 0)
                              _buildLegendItem('Organizations', Colors.purple[600]!, totalOrganizations, isMobile),
                          ],
                        ),
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

  List<PieChartSectionData> _getPieChartSections(int totalTrainers, int totalTrainees, int totalOrganizations, int totalUsers, bool isMobile) {
    List<PieChartSectionData> sections = [];

    if (totalTrainers > 0) {
      sections.add(
        PieChartSectionData(
          value: totalTrainers.toDouble(),
          title: '${(totalTrainers / totalUsers * 100).toStringAsFixed(0)}%',
          color: AppTheme.primaryGreen,
          radius: isMobile ? 55 : 75,
          titleStyle: TextStyle(
            fontSize: isMobile ? 12 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (totalTrainees > 0) {
      sections.add(
        PieChartSectionData(
          value: totalTrainees.toDouble(),
          title: '${(totalTrainees / totalUsers * 100).toStringAsFixed(0)}%',
          color: Colors.orange[600],
          radius: isMobile ? 55 : 75,
          titleStyle: TextStyle(
            fontSize: isMobile ? 12 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (totalOrganizations > 0) {
      sections.add(
        PieChartSectionData(
          value: totalOrganizations.toDouble(),
          title: '${(totalOrganizations / totalUsers * 100).toStringAsFixed(0)}%',
          color: Colors.purple[600],
          radius: isMobile ? 55 : 75,
          titleStyle: TextStyle(
            fontSize: isMobile ? 12 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
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
