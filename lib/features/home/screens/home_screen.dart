import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../incidents/widgets/incident_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<IncidentProvider>().fetchUserIncidents(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final incidentProvider = context.watch<IncidentProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${user?.name.split(' ').first ?? 'Student'} 👋',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Help make our campus safer.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'), // Placeholder
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B61FF), Color(0xFF9D8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('See an issue\non campus?',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Report it and help improve our learning environment.',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/create-incident'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Report an Issue'),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Report Summary
              const Text('Report Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _summaryCard('12', 'My Reports', Colors.purple),
                  _summaryCard('5', 'In Progress', Colors.blue),
                  _summaryCard('4', 'Resolved', Colors.green),
                  _summaryCard('3', 'Submitted', Colors.orange),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Reports
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.push('/my-incidents'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // List
              if (incidentProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (incidentProvider.incidents.isEmpty)
                const Center(child: Text('No incidents reported yet.'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: incidentProvider.incidents.take(3).length,
                  itemBuilder: (context, index) {
                    final incident = incidentProvider.incidents[index];
                    return IncidentCard(
                      incident: incident,
                      onTap: () => context.push('/incident-details', extra: incident),
                    );
                  },
                ),
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
            Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}