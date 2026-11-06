import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class PhotoPicker extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasImage;

  const PhotoPicker({super.key, required this.onTap, this.hasImage = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasImage ? Icons.check_circle : Icons.add_a_photo_outlined, 
                 color: hasImage ? AppConstants.successColor : Colors.grey, size: 30),
            const SizedBox(height: 8),
            Text(
              hasImage ? 'Photo attached' : 'Tap to add photos', 
              style: TextStyle(color: hasImage ? AppConstants.successColor : Colors.grey)
            ),
          ],
        ),
      ),
    );
  }
}