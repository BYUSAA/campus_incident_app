import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class IncidentFilterSheet extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterSelected;

  const IncidentFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Submitted', 'In Progress', 'Resolved'];

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...filters.map((f) => RadioListTile<String>(
                title: Text(f),
                value: f,
                groupValue: currentFilter,
                activeColor: AppConstants.primaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  if (val != null) {
                    onFilterSelected(val);
                    Navigator.pop(context);
                  }
                },
              )),
        ],
      ),
    );
  }
}