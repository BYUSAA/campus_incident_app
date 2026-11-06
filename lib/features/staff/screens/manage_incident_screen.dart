import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/incident.dart';
import '../../../providers/incident_provider.dart';
import '../widgets/status_update_control.dart';

class ManageIncidentScreen extends StatelessWidget {
  final Incident incident;

  const ManageIncidentScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(incident.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Reported by: ${incident.reportedBy}', style: const TextStyle(color: AppConstants.greyText)),
            Text(DateFormatter.formatDateTime(incident.createdAt), style: const TextStyle(color: AppConstants.greyText, fontSize: 12)),
            const Divider(height: 32),
            
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(incident.category),
            const SizedBox(height: 16),
            
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(incident.location),
            const SizedBox(height: 16),
            
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(incident.description, style: const TextStyle(height: 1.5)),
            const Divider(height: 32),
            
            const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StatusUpdateControl(
              currentStatus: incident.status,
              onStatusChanged: (newStatus) async {
                await context.read<IncidentProvider>().updateStatus(incident.id, newStatus);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}