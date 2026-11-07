import 'package:flutter/material.dart';

class IncidentCategory {
  const IncidentCategory({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}

abstract final class IncidentCategories {
  static const List<IncidentCategory> all = [
    IncidentCategory(name: 'Facilities', icon: Icons.business),
    IncidentCategory(name: 'Water', icon: Icons.water_drop),
    IncidentCategory(name: 'Electricity', icon: Icons.electric_bolt),
    IncidentCategory(name: 'Safety', icon: Icons.shield),
    IncidentCategory(name: 'Sanitation', icon: Icons.cleaning_services),
  ];

  static List<String> get names =>
      all.map((category) => category.name).toList(growable: false);

  static IconData getIcon(String categoryName) {
    for (final category in all) {
      if (category.name == categoryName) return category.icon;
    }
    return all.first.icon;
  }
}