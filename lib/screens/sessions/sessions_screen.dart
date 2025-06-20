import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

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
                  'Training Sessions',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Schedule Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                  ),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search sessions...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: 'All Status',
                            items: const [
                              DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                              DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                              DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                            ],
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Sessions management interface will be implemented here',
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
