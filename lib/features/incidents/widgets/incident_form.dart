import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../models/incident.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import 'package:provider/provider.dart';
import 'category_selector.dart';
import 'photo_picker.dart';

class IncidentForm extends StatefulWidget {
  final Incident? initialIncident; // If not null, we are editing
  final VoidCallback onSuccess;

  const IncidentForm({super.key, this.initialIncident, required this.onSuccess});

  @override
  State<IncidentForm> createState() => _IncidentFormState();
}

class _IncidentFormState extends State<IncidentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late String _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialIncident?.title ?? '');
    _descController = TextEditingController(text: widget.initialIncident?.description ?? '');
    _locationController = TextEditingController(text: widget.initialIncident?.location ?? '');
    _selectedCategory = widget.initialIncident?.category ?? 'Facilities';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;

      final incidentProvider = context.read<IncidentProvider>();

      if (widget.initialIncident == null) {
        // Create
        final newIncident = Incident(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          status: 'Submitted',
          reportedBy: user.uid,
          createdAt: DateTime.now(),
        );
        await incidentProvider.submitIncident(newIncident);
      } else {
        // Edit
        final updatedIncident = Incident(
          id: widget.initialIncident!.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          status: widget.initialIncident!.status,
          reportedBy: widget.initialIncident!.reportedBy,
          createdAt: widget.initialIncident!.createdAt,
        );
        // Note: Add updateIncident method to your IncidentProvider/FirestoreService
        // await incidentProvider.updateIncident(updatedIncident);
      }

      widget.onSuccess();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select a category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          CategorySelector(
            selectedCategory: _selectedCategory,
            onCategorySelected: (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 24),
          
          _buildTextField('Title', 'Briefly describe the issue...', _titleController),
          const SizedBox(height: 16),
          _buildTextField('Description', 'Provide more details...', _descController, maxLines: 4),
          const SizedBox(height: 16),
          _buildTextField('Location', 'e.g. Block B — Room 204', _locationController),
          
          const SizedBox(height: 24),
          const Text('Add a photo (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          PhotoPicker(onTap: () {}), // Implement ImagePicker logic here
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : Text(widget.initialIncident == null ? 'Submit Report' : 'Update Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (val) => Validators.validateRequired(val, label),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}