import 'package:flutter/material.dart';
import '../models/stats_model.dart';
import '../utils/theme.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final StatsModel stats;
  final bool isDonutChart;

  const ChartCard({
    super.key,
    required this.title,
    required this.stats,
    this.isDonutChart = false,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: isDonutChart ? 'All Users' : '6m',
                      items: isDonutChart
                          ? const [
                        DropdownMenuItem(value: 'All Users', child: Text('All Users')),
                        DropdownMenuItem(value: 'Trainers', child: Text('Trainers')),
                        DropdownMenuItem(value: 'Trainees', child: Text('Trainees')),
                        DropdownMenuItem(value: 'Organizations', child: Text('Organizations')),
                      ]
                          : const [
                        DropdownMenuItem(value: '1m', child: Text('Last Month')),
                        DropdownMenuItem(value: '3m', child: Text('Last 3 Months')),
                        DropdownMenuItem(value: '6m', child: Text('Last 6 Months')),
                        DropdownMenuItem(value: '1y', child: Text('Last Year')),
                      ],
                      onChanged: (value) {},
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: isDonutChart ? _buildDonutChart() : _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 8,
                                height: 80 + (index * 10).toDouble(),
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 60 + (index * 8).toDouble(),
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 40 + (index * 6).toDouble(),
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightBlue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[index],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Trainees', AppTheme.primaryBlue),
            const SizedBox(height: 8),
            _buildLegendItem('Trainers', AppTheme.primaryGreen),
            const SizedBox(height: 8),
            _buildLegendItem('Organizations', AppTheme.lightBlue),
          ],
        ),
      ],
    );
  }

  Widget _buildDonutChart() {
    final activePercentage = stats.userActivePercentage;
    final inactivePercentage = 100 - activePercentage;

    return Row(
      children: [
        Expanded(
          child: Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!, width: 20),
                    ),
                  ),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue, width: 20),
                    ),
                    child: CircularProgressIndicator(
                      value: activePercentage / 100,
                      strokeWidth: 20,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${activePercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDonutLegendItem(
              'Active Users',
              stats.activeUsers.toString(),
              AppTheme.primaryBlue,
              activePercentage,
            ),
            const SizedBox(height: 16),
            _buildDonutLegendItem(
              'Inactive Users',
              stats.inactiveUsers.toString(),
              Colors.grey[300]!,
              inactivePercentage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDonutLegendItem(String label, String value, Color color, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
