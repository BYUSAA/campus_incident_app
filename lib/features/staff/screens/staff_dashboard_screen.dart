import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import '../../incidents/widgets/incident_card.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<IncidentProvider>().fetchAllIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final all = provider.incidents.length;
    final unresolved = provider.incidents.where((item) => item.status != 'Resolved').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<IncidentProvider>().fetchAllIncidents(),
        child: provider.isLoading && provider.incidents.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null
                ? Center(child: Text('Could not load incidents: ${provider.errorMessage}'))
                : ListView(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    children: [
                      Row(
                        children: [
                          _summaryCard('Total reports', all.toString(), AppConstants.primaryColor),
                          _summaryCard('Needs attention', unresolved.toString(), Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Incident queue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (provider.incidents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('There are no incidents to review.')),
                        )
                      else
                        ...provider.incidents.map(
                          (incident) => IncidentCard(
                            incident: incident,
                            onTap: () => context.push('/staff/manage', extra: incident),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _summaryCard(String label, String count, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
