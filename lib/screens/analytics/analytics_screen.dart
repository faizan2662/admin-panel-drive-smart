import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
                  'Analytics & Reports',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'Last 30 days',
                          items: const [
                            DropdownMenuItem(value: 'Last 7 days', child: Text('Last 7 days')),
                            DropdownMenuItem(value: 'Last 30 days', child: Text('Last 30 days')),
                            DropdownMenuItem(value: 'Last 90 days', child: Text('Last 90 days')),
                            DropdownMenuItem(value: 'Last year', child: Text('Last year')),
                          ],
                          onChanged: (value) {},
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Export'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Analytics dashboard will be implemented here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
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
