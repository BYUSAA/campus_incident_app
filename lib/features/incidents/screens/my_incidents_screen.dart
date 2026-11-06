import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import '../widgets/incident_card.dart';

class MyIncidentsScreen extends StatefulWidget {
  const MyIncidentsScreen({super.key});

  @override
  State<MyIncidentsScreen> createState() => _MyIncidentsScreenState();
}

class _MyIncidentsScreenState extends State<MyIncidentsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user != null) context.read<IncidentProvider>().fetchUserIncidents(user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final filtered = provider.incidents.where((incident) {
      return _selectedFilter == 'All' || incident.status == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: ['All', 'Submitted', 'In Progress', 'Resolved'].map((filter) {
                final selected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: AppConstants.primaryColor,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.incidents.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                    ? Center(child: Text('Could not load your reports: ${provider.errorMessage}'))
                    : filtered.isEmpty
                        ? const Center(child: Text('You have no reports in this status.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final incident = filtered[index];
                              return IncidentCard(
                                incident: incident,
                                onTap: () => context.push('/incident-details', extra: incident),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
