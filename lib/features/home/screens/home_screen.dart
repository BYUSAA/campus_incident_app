import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import '../../incidents/widgets/incident_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final incidents = context.watch<IncidentProvider>();

    final total = incidents.incidents.length;
    final inProgress = incidents.incidents.where((item) => item.status == 'In Progress').length;
    final resolved = incidents.incidents.where((item) => item.status == 'Resolved').length;
    final submitted = incidents.incidents.where((item) => item.status == 'Submitted').length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<IncidentProvider>().refresh();
          },
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.name.split(' ').first ?? 'Student'}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Help make our campus safer.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person_outline, color: AppConstants.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4EFF), Color(0xFF9D8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'See an issue on campus?',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Report it with the location and details so the right team can respond.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/create-incident'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppConstants.primaryColor,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Report an Issue'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Your report summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _summaryCard(total.toString(), 'All', AppConstants.primaryColor),
                  _summaryCard(submitted.toString(), 'Submitted', Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _summaryCard(inProgress.toString(), 'In progress', Colors.blue),
                  _summaryCard(resolved.toString(), 'Resolved', Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.push('/my-incidents'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              if (incidents.isLoading && incidents.incidents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (incidents.errorMessage != null)
                Text('Could not load reports: ${incidents.errorMessage}')
              else if (incidents.incidents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('You have not submitted an incident yet.')),
                )
              else
                ...incidents.incidents.take(3).map(
                  (incident) => IncidentCard(
                    incident: incident,
                    onTap: () => context.push('/incident-details', extra: incident),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String count, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
