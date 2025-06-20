import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class OrganizationsScreen extends StatelessWidget {
  const OrganizationsScreen({super.key});

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
                  'Organizations',
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
                    label: const Text('Add Organization'),
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
                                hintText: 'Search organizations...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: 'All Types',
                            items: const [
                              DropdownMenuItem(value: 'All Types', child: Text('All Types')),
                              DropdownMenuItem(value: 'Driving School', child: Text('Driving School')),
                              DropdownMenuItem(value: 'Transportation', child: Text('Transportation')),
                              DropdownMenuItem(value: 'Training Center', child: Text('Training Center')),
                            ],
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Organizations management interface will be implemented here',
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
