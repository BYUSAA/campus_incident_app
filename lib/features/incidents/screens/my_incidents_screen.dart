import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
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
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    
    // Filter logic
    final filteredIncidents = provider.incidents.where((incident) {
      if (_selectedFilter == 'All') return true;
      return incident.status == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: ['All', 'Submitted', 'In Progress', 'Resolved'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedFilter = filter),
                    selectedColor: AppConstants.primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  ),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredIncidents.isEmpty
                    ? const Center(child: Text('No reports found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
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