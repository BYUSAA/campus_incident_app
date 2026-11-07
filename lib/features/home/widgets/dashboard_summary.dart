import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
    required this.myReports,
    required this.inProgress,
    required this.resolved,
    required this.submitted,
  });

  final int myReports;
  final int inProgress;
  final int resolved;
  final int submitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryCard(count: myReports, label: 'My Reports', color: AppConstants.primaryColor, icon: Icons.assignment),
        _SummaryCard(count: inProgress, label: 'In Progress', color: AppConstants.infoColor, icon: Icons.hourglass_empty),
        _SummaryCard(count: resolved, label: 'Resolved', color: AppConstants.successColor, icon: Icons.check_circle_outline),
        _SummaryCard(count: submitted, label: 'Submitted', color: AppConstants.warningColor, icon: Icons.send),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  final int count;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}