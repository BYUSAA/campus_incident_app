import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/incident_status.dart';

class StatusUpdateControl extends StatelessWidget {
  const StatusUpdateControl({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final availableStatuses = IncidentStatus.optionsFor(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isExpanded: true,
          items: availableStatuses
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ),
              )
              .toList(),
          onChanged: (status) {
            if (status != null && status != currentStatus) {
              onStatusChanged(status);
            }
          },
        ),
      ),
    );
  }
}
