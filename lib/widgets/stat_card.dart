import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final double growth;
  final IconData icon;
  final Color color;
  final int activeCount;
  final int inactiveCount;
  final double activePercentage;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.color,
    required this.activeCount,
    required this.inactiveCount,
    required this.activePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),

            // Value and Growth
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 12,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '+${growth.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Active/Inactive breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active: $activeCount',
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Inactive: $inactiveCount',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: activePercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
