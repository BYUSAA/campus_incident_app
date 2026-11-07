import 'package:flutter/material.dart';

import '../../../models/incident.dart';
import '../../incidents/widgets/incident_status_badge.dart';

class StaffIncidentCard extends StatelessWidget {
  const StaffIncidentCard({
    super.key,
    required this.incident,
    required this.onManage,
  });

  final Incident incident;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onManage,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.assignment_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${incident.category} • ${incident.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IncidentStatusBadge(status: incident.status),
            ],
          ),
        ),
      ),
    );
  }
}