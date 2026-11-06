import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/incident_form.dart';

class CreateIncidentScreen extends StatelessWidget {
  const CreateIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: IncidentForm(
          onSuccess: () => context.pop(),
        ),
      ),
    );
  }
}