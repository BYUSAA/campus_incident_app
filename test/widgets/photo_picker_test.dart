import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/features/incidents/widgets/photo_picker.dart';

void main() {
  testWidgets('allows an existing uploaded photo to be removed', (tester) async {
    var existingPhotoRemoved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhotoPicker(
            existingImageUrl: 'https://example.invalid/incident-photo.jpg',
            onImageSelected: (_) {},
            onExistingImageRemoved: () {
              existingPhotoRemoved = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Remove photo'), findsOneWidget);
    await tester.tap(find.text('Remove photo'));
    await tester.pump();

    expect(existingPhotoRemoved, isTrue);
  });
}