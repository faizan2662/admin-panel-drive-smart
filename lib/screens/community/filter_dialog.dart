import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;
  final List<String> availableFilters;

  const FilterDialog({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.availableFilters = const ['All Posts', 'Admin', 'Trainer', 'Trainee', 'Organization'],
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Filter Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          ...availableFilters.map((filter) =>
              RadioListTile<String>(
                title: Text(filter),
                value: filter,
                groupValue: currentFilter,
                onChanged: (value) {
                  if (value != null) {
                    onFilterChanged(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
          ).toList(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
