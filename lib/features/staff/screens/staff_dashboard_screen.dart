import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/incident_provider.dart';
import '../../incidents/widgets/incident_card.dart';
import '../manage_incident_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: In a real app, fetch ALL incidents here, not just user's
    final provider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Dashboard'), automaticallyImplyLeading: false),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              itemCount: provider.incidents.length,
              itemBuilder: (context, index) {
                final incident = provider.incidents[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => ManageIncidentScreen(incident: incident))
                  ),
                  child: IncidentCard(incident: incident, onTap: () {}),
                );
              },
            ),
    );
  }
}