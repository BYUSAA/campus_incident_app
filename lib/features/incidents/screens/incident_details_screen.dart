import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/incident.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final Incident incident;

  const IncidentDetailsScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(incident.category, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      _buildStatusBadge(incident.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Submitted on ${DateFormat('MMM d, yyyy').format(incident.createdAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            
            const Text('Status Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timelineStep('Submitted', true, true),
                _timelineStep('In Progress', incident.status != 'Submitted', false),
                _timelineStep('Resolved', incident.status == 'Resolved', false),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(incident.description, style: const TextStyle(color: Colors.black87, height: 1.5)),
            
            const SizedBox(height: 24),
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(incident.location, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Resolved' ? Colors.green : status == 'In Progress' ? Colors.blue : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _timelineStep(String title, bool isActive, bool isFirst) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppConstants.primaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: isActive ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }
}