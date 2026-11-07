import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/incident_status.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import '../../incidents/widgets/incident_card.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await context.read<AuthProvider>().logout();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not sign out: $error')),
      );
    }
  }

  Future<void> _refresh() async {
    context.read<IncidentProvider>().refresh();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final allIncidents = provider.incidents;
    final total = allIncidents.length;
    final unresolved =
        allIncidents.where((item) => item.status != 'Resolved').length;

    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filtered = allIncidents.where((incident) {
      final matchesSearch = normalizedQuery.isEmpty ||
          incident.title.toLowerCase().contains(normalizedQuery) ||
          incident.description.toLowerCase().contains(normalizedQuery) ||
          incident.location.toLowerCase().contains(normalizedQuery) ||
          incident.category.toLowerCase().contains(normalizedQuery) ||
          (incident.reporterName ?? '').toLowerCase().contains(normalizedQuery);
      final matchesStatus =
          _statusFilter == 'All' || incident.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            Row(
              children: [
                _summaryCard(
                  'Total reports',
                  total.toString(),
                  AppConstants.primaryColor,
                ),
                _summaryCard(
                  'Needs attention',
                  unresolved.toString(),
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search title, location, category or reporter',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', ...IncidentStatus.values].map((status) {
                  final selected = _statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _statusFilter = status),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Incident queue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (provider.isLoading && allIncidents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Could not load incidents: ${provider.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                    TextButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    allIncidents.isEmpty
                        ? 'There are no incidents to review.'
                        : 'No incidents match your search or filter.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...filtered.map(
                (incident) => IncidentCard(
                  incident: incident,
                  onTap: () => context.push(
                    '/staff/manage',
                    extra: incident,
                  ),
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
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
