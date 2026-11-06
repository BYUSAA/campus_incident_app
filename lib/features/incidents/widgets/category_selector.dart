import 'package:flutter/material.dart';

import '../../../core/constants/incident_categories.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: 'Incident category'),
      items: IncidentCategories.all
          .map(
            (category) => DropdownMenuItem<String>(
              value: category.name,
              child: Row(
                children: [
                  Icon(category.icon, size: 18),
                  const SizedBox(width: 10),
                  Text(category.name),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
      validator: (selected) =>
          selected == null ? 'Choose an incident category.' : null,
    );
  }
}
