import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/incident.dart';
import '../../../providers/incident_provider.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
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
  bool _isDeleting = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.incident.status;
  }

  Future<void> _updateStatus(String status) async {
    if (_isUpdating || _isDeleting) return;
    setState(() => _isUpdating = true);

    try {
      await context.read<IncidentProvider>().updateStatus(
        widget.incident.id,
        status,
      );
      if (mounted) setState(() => _currentStatus = status);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update the status: $error')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteIncident() async {
    if (_isUpdating || _isDeleting) return;
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete incident?',
      message:
          'This permanently removes the report and attempts to remove its attached photo.',
      confirmLabel: 'Delete report',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await context.read<IncidentProvider>().deleteIncident(widget.incident.id);
      if (mounted) context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete the incident: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  int _statusRank(String status) {
    switch (status) {
      case 'In Progress':
        return 1;
      case 'Resolved':
        return 2;
      case 'Submitted':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final incidentState = context.watch<IncidentProvider>();
    Incident? latestIncident;
    for (final candidate in incidentState.incidents) {
      if (candidate.id == widget.incident.id) {
        latestIncident = candidate;
        break;
      }
    }
    final incident = latestIncident ?? widget.incident;
    // Status transitions are forward-only, so the furthest status from the
    // latest Firestore snapshot or this screen's optimistic update wins.
    final currentStatus = _statusRank(incident.status) >= _statusRank(_currentStatus)
        ? incident.status
        : _currentStatus;
    final imageUrl = incident.imageUrl ??
        (incident.photoUrls.isEmpty ? null : incident.photoUrls.first);
    final isBusy = _isUpdating || _isDeleting;

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
            Text(
              'Reported by: ${incident.reporterName ?? incident.reportedBy}',
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(incident.createdAt),
              style: const TextStyle(
                color: AppConstants.greyText,
                fontSize: 12,
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(incident.category),
            const SizedBox(height: 16),
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(incident.location),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            const Text(
              'Update status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StatusUpdateControl(
              currentStatus: currentStatus,
              enabled: !isBusy,
              onStatusChanged: _updateStatus,
            ),
            if (isBusy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _deleteIncident,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete report'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}