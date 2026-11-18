import 'package:flutter/material.dart';

class IncidentSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const IncidentSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Search reports...',
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(vertical: 0),
        fillColor: Colors.white,
      ),
    );
  }
}