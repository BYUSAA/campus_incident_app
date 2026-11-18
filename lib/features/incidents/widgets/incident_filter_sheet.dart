import 'package:flutter/material.dart';

class IncidentFilterSheet extends StatelessWidget {
  const IncidentFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  final String currentFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const filters = ['All', 'Submitted', 'In Progress', 'Resolved'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Status',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: currentFilter,
            onChanged: (value) {
              if (value == null) return;
              onFilterSelected(value);
              Navigator.pop(context);
            },
            child: Column(
              children: [
                for (final filter in filters)
                  RadioListTile<String>(
                    title: Text(filter),
                    value: filter,
                    activeColor: theme.colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}