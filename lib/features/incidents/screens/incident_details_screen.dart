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

  Future<void> _deleteIncident(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This will permanently remove the report.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<IncidentProvider>().deleteIncident(incident.id);
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
    final user = context.watch<AuthProvider>().user;
    final canEdit = user != null &&
        user.uid == incident.reportedBy &&
        incident.status == 'Submitted';
    final imageUrl = incident.imageUrl ??
        (incident.photoUrls.isEmpty ? null : incident.photoUrls.first);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/edit-incident', extra: incident);
                } else if (value == 'delete') {
                  _deleteIncident(context);
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
                  errorBuilder: (context, error, stack) =>
                      _imagePlaceholder(context),
                ),
              )
            else
              _imagePlaceholder(context),
            const SizedBox(height: 20),
            Text(
              incident.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(incident.category)),
                _statusBadge(context, incident.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Submitted on ${DateFormat('MMM d, yyyy • h:mm a').format(incident.createdAt)}',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
            if (incident.reporterName?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Reported by ${incident.reporterName}'),
            ],
            const Divider(height: 32),
            Text('Description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(incident.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 24),
            Text('Location', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(child: Text(incident.location)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Status progress', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 14),
            _timeline(context),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Icon(
        Icons.image_outlined,
        color: colors.onSurfaceVariant,
        size: 48,
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;
    final color = status == 'Resolved'
        ? colors.tertiary
        : status == 'In Progress'
            ? colors.primary
            : colors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _timeline(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentStep = incident.status == 'Resolved'
        ? 2
        : incident.status == 'In Progress'
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
                  color: active ? colors.primary : colors.surfaceContainerHighest,
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
                  color: active ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}