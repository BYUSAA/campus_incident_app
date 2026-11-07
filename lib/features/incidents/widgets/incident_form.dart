import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/validators.dart';
import '../../../models/incident.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/incident_provider.dart';
import 'category_selector.dart';
import 'photo_picker.dart';

class IncidentForm extends StatefulWidget {
  const IncidentForm({
    super.key,
    this.initialIncident,
    required this.onSuccess,
  });

  final Incident? initialIncident;
  final VoidCallback onSuccess;

  @override
  State<IncidentForm> createState() => _IncidentFormState();
}

class _IncidentFormState extends State<IncidentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  late String _selectedCategory;
  File? _selectedPhoto;
  bool _removeExistingPhoto = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIncident;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(text: initial?.description ?? '');
    _locationController = TextEditingController(text: initial?.location ?? '');
    _selectedCategory = initial?.category ?? 'Facilities';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again before submitting.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = context.read<IncidentProvider>();
      final existing = widget.initialIncident;
      if (existing == null) {
        final incident = Incident(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          status: 'Submitted',
          reportedBy: user.uid,
          reporterName: user.name,
          createdAt: DateTime.now(),
        );
        await provider.submitIncident(incident, photo: _selectedPhoto);
      } else {
        final updated = existing.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          reporterName: user.name,
        );
        await provider.updateIncident(\n          updated,\n          photo: _selectedPhoto,\n          removePhoto: _removeExistingPhoto,\n        );
      }

      if (mounted) widget.onSuccess();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the report: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _textField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    required int maxLength,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: TextCapitalization.sentences,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CategorySelector(
            value: _selectedCategory,
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 24),
          _textField(
            'Title',
            'Briefly describe the issue…',
            _titleController,
            maxLength: 100,
            validator: Validators.validateTitle,
          ),
          const SizedBox(height: 16),
          _textField(
            'Description',
            'Provide the details someone needs to respond…',
            _descriptionController,
            maxLines: 4,
            maxLength: 1000,
            validator: Validators.validateDescription,
          ),
          const SizedBox(height: 16),
          _textField(
            'Location',
            'For example: Block B, Room 204',
            _locationController,
            maxLength: 160,
            validator: Validators.validateLocation,
          ),
          const SizedBox(height: 24),
          const Text(
            'Attach a photo (optional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          PhotoPicker(
            selectedImage: _selectedPhoto,
            existingImageUrl: _removeExistingPhoto
                ? null
                : widget.initialIncident?.imageUrl ??
                    (widget.initialIncident?.photoUrls.isNotEmpty == true
                        ? widget.initialIncident!.photoUrls.first
                        : null),
            onImageSelected: (file) => setState(() => _selectedPhoto = file),
            onExistingImageRemoved: () =>
                setState(() => _removeExistingPhoto = true),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(existingButtonLabel),
            ),
          ),
        ],
      ),
    );
  }

  String get existingButtonLabel =>
      widget.initialIncident == null ? 'Submit Report' : 'Save Changes';
}