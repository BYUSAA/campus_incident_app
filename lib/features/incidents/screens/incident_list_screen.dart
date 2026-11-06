import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import '../widgets/incident_card.dart';
import '../widgets/incident_filter_sheet.dart';
import '../widgets/incident_search_bar.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user != null) context.read<IncidentProvider>().watchForUser(user);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final isStaff = context.watch<AuthProvider>().user?.isStaff ?? false;

    final filtered = provider.incidents.where((incident) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = incident.title.toLowerCase().contains(query) ||
          incident.description.toLowerCase().contains(query) ||
          incident.location.toLowerCase().contains(query) ||
          incident.category.toLowerCase().contains(query);
      final matchesStatus = _statusFilter == 'All' || incident.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isStaff ? 'All Campus Reports' : 'My Campus Reports'),
        actions: [
          IconButton(
            tooltip: 'Filter by status',
            icon: const Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (context) => IncidentFilterSheet(
                currentFilter: _statusFilter,
                onFilterSelected: (value) => setState(() => _statusFilter = value),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: IncidentSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.incidents.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                    ? Center(child: Text('Could not load reports: ${provider.errorMessage}'))
                    : filtered.isEmpty
                        ? const Center(child: Text('No reports match your search.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
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
