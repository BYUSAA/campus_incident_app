import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/incident.dart';
import '../widgets/incident_form.dart';

class EditIncidentScreen extends StatelessWidget {
  final Incident incident;

  const EditIncidentScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: IncidentForm(
          initialIncident: incident,
          onSuccess: () => context.pop(),
        ),
      ),
    );
  }
}