import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class StatusUpdateControl extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const StatusUpdateControl({super.key, required this.currentStatus, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isExpanded: true,
          items: ['Submitted', 'In Progress', 'Resolved'].map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (val) {
            if (val != null) onStatusChanged(val);
          },
        ),
      ),
    );
  }
}