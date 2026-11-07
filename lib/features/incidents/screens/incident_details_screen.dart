import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/incident.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';

class IncidentDetailsScreen extends StatelessWidget {
  const IncidentDetailsScreen({super.key, required this.incident});

  final Incident incident;

  Future<void> _deleteIncident(
    BuildContext context,
    Incident currentIncident,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This will permanently remove the report.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<IncidentProvider>().deleteIncident(currentIncident.id);
      if (context.mounted) context.pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete the report: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveIncident =
        context.watch<IncidentProvider>().findById(incident.id) ?? incident;
    final user = context.watch<AuthProvider>().user;
    final canEdit = user != null &&
        user.uid == liveIncident.reportedBy &&
        liveIncident.status == 'Submitted';
    final imageUrl = liveIncident.imageUrl ??
        (liveIncident.photoUrls.isEmpty ? null : liveIncident.photoUrls.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/edit-incident', extra: liveIncident);
                } else if (value == 'delete') {
                  _deleteIncident(context, liveIncident);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit report')),
                PopupMenuItem(value: 'delete', child: Text('Delete report')),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => _imagePlaceholder(),
                ),
              )
            else
              _imagePlaceholder(),
            const SizedBox(height: 20),
            Text(liveIncident.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(liveIncident.category)),
                _statusBadge(liveIncident.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Submitted on ${DateFormat('MMM d, yyyy • h:mm a').format(liveIncident.createdAt)}',
              style: const TextStyle(color: AppConstants.greyText, fontSize: 12),
            ),
            if (liveIncident.reporterName?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Reported by ${liveIncident.reporterName}'),
            ],
            const Divider(height: 32),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(liveIncident.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 24),
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppConstants.greyText),
                const SizedBox(width: 6),
                Expanded(child: Text(liveIncident.location)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Status progress', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _timeline(),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 48),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'Resolved'
        ? Colors.green
        : status == 'In Progress'
            ? Colors.blue
            : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _timeline() {
    final currentStep = liveIncident.status == 'Resolved'
        ? 2
        : liveIncident.status == 'In Progress'
            ? 1
            : 0;
    const steps = ['Submitted', 'In Progress', 'Resolved'];
    return Row(
      children: List.generate(steps.length, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: active ? AppConstants.primaryColor : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: active
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? AppConstants.primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
