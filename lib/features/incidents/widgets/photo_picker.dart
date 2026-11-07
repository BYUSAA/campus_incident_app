import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({
    super.key,
    required this.onImageSelected,
    this.selectedImage,
    this.existingImageUrl,
    this.onExistingImageRemoved,
  });

  final File? selectedImage;
  final String? existingImageUrl;
  final ValueChanged<File?> onImageSelected;
  final VoidCallback? onExistingImageRemoved;

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (!mounted || source == null) return;
    setState(() => _isPicking = true);
    try {
      final selected = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (selected != null && mounted) {
        widget.onImageSelected(File(selected.path));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select the photo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _removePhoto() {
    if (widget.selectedImage != null) {
      widget.onImageSelected(null);
    } else if (widget.existingImageUrl != null) {
      widget.onExistingImageRemoved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.selectedImage;
    final existingUrl = widget.existingImageUrl;
    final hasPhoto = image != null || existingUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isPicking ? null : _chooseImage,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isPicking
                ? const Center(child: CircularProgressIndicator())
                : image != null
                    ? Image.file(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : existingUrl != null
                        ? Image.network(
                            existingUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const _PhotoPlaceholder(
                              message: 'The saved photo could not be loaded.',
                            ),
                          )
                        : const _PhotoPlaceholder(
                            message: 'Choose a photo from your camera or gallery',
                          ),
          ),
        ),
        if (hasPhoto)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _removePhoto,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove photo'),
            ),
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isPicking ? null : _chooseImage,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add photo'),
            ),
          ),
      ],
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              color: AppConstants.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}