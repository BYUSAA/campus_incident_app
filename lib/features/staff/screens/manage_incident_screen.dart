import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/incident.dart';
import '../../../providers/incident_provider.dart';
import '../widgets/status_update_control.dart';

class ManageIncidentScreen extends StatefulWidget {
  const ManageIncidentScreen({
    super.key,
    required this.incident,
  });

  final Incident incident;

  @override
  State<ManageIncidentScreen> createState() => _ManageIncidentScreenState();
}

class _ManageIncidentScreenState extends State<ManageIncidentScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String status) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      await context.read<IncidentProvider>().updateStatus(
        widget.incident.id,
        status,
      );
      if (mounted) context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update the status: $error')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final imageUrl = incident.imageUrl ??
        (incident.photoUrls.isEmpty ? null : incident.photoUrls.first);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Reported by: ${incident.reporterName ?? incident.reportedBy}'),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(incident.createdAt),
              style: const TextStyle(
                color: AppConstants.greyText,
                fontSize: 12,
              ),
            ),
            const Divider(height: 32),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(incident.category),
            const SizedBox(height: 16),
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(incident.location),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(incident.description, style: const TextStyle(height: 1.5)),
            if (imageUrl != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 190,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 36),
                  ),
                ),
              ),
            ],
            const Divider(height: 32),
            const Text('Update status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StatusUpdateControl(
              currentStatus: incident.status,
              enabled: !_isUpdating,
              onStatusChanged: _updateStatus,
            ),
            if (_isUpdating) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}