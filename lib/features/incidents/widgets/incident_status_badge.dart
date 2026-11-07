import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class IncidentStatusBadge extends StatelessWidget {
  final String status;

  const IncidentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Resolved':
        color = AppConstants.successColor;
        break;
      case 'In Progress':
        color = AppConstants.infoColor;
        break;
      default:
        color = AppConstants.warningColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}