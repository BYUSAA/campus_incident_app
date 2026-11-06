import 'package:flutter/material.dart';

class IncidentCategory {
  final String name;
  final IconData icon;

  const IncidentCategory({required this.name, required this.icon});
}

class IncidentCategories {
  static const List<IncidentCategory> all = [
    IncidentCategory(name: 'Facilities', icon: Icons.business),
    IncidentCategory(name: 'Water', icon: Icons.water_drop),
    IncidentCategory(name: 'Electricity', icon: Icons.electric_bolt),
    IncidentCategory(name: 'Safety', icon: Icons.shield),
    IncidentCategory(name: 'Sanitation', icon: Icons.cleaning_services),
  ];

  static IconData getIcon(String categoryName) {
    return all.firstWhere(
      (element) => element.name == categoryName,
      orElse: () => const IncidentCategory(name: 'Other', icon: Icons.error),
    ).icon;
  }
}