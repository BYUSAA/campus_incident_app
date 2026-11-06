import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/incident_provider.dart';
import '../widgets/incident_card.dart';
import '../widgets/incident_search_bar.dart';
import '../widgets/incident_filter_sheet.dart';

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
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    final filteredIncidents = provider.incidents.where((incident) {
      final matchesSearch = incident.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          incident.location.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _statusFilter == 'All' || incident.status == _statusFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => IncidentFilterSheet(
                  currentFilter: _statusFilter,
                  onFilterSelected: (val) => setState(() => _statusFilter = val),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: IncidentSearchBar(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredIncidents.isEmpty
                    ? const Center(child: Text('No reports found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                        itemCount: filteredIncidents.length,
                        itemBuilder: (context, index) {
                          final incident = filteredIncidents[index];
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