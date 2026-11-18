import 'package:flutter/material.dart';

import '../../../core/constants/incident_status.dart';

/// Lets staff pick the next status for an incident. Every status is shown so
/// the workflow is visible; only the current status and the next allowed step
/// can be selected. Selecting does not save — the screen's "Update status"
/// button does.
class StatusUpdateControl extends StatelessWidget {
  const StatusUpdateControl({
    super.key,
    required this.currentStatus,
    required this.selectedStatus,
    required this.onSelected,
    this.enabled = true,
  });

  final String currentStatus;
  final String selectedStatus;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final allowed = IncidentStatus.optionsFor(currentStatus);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in IncidentStatus.values)
          ChoiceChip(
            label: Text(status),
            selected: status == selectedStatus,
            onSelected: enabled && allowed.contains(status)
                ? (_) => onSelected(status)
                : null,
          ),
      ],
    );
  }
}
