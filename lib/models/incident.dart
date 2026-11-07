import 'package:cloud_firestore/cloud_firestore.dart';

const Object _notProvided = Object();

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    this.imageUrl,
    this.photoUrls = const [],
    required this.reportedBy,
    this.reporterName,
    this.assignedTo,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String? imageUrl;
  final List<String> photoUrls;
  final String reportedBy;
  final String? reporterName;
  final String? assignedTo;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    final images = photoUrls.isNotEmpty
        ? photoUrls
        : (imageUrl == null ? <String>[] : <String>[imageUrl!]);
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': status,
      'imageUrl': images.isEmpty ? null : images.first,
      'photoUrls': images,
      'reportedBy': reportedBy,
      'reporterName': reporterName,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    final rawImages = map['photoUrls'];
    final images = rawImages is List
        ? rawImages.whereType<String>().where((url) => url.isNotEmpty).toList(
              growable: false,
            )
        : <String>[];
    final legacyImage = _nullableString(map['imageUrl']);
    final normalizedImages = images.isNotEmpty
        ? images
        : (legacyImage == null ? <String>[] : <String>[legacyImage]);

    return Incident(
      id: id,
      title: _string(map['title']),
      description: _string(map['description']),
      category: _string(map['category'], fallback: 'Other'),
      location: _string(map['location']),
      status: _string(map['status'], fallback: 'Submitted'),
      imageUrl: normalizedImages.isEmpty ? null : normalizedImages.first,
      photoUrls: normalizedImages,
      reportedBy: _string(map['reportedBy']),
      reporterName: _nullableString(map['reporterName']),
      assignedTo: _nullableString(map['assignedTo']),
      createdAt: _dateTimeFrom(map['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static String _string(Object? value, {String fallback = ''}) =>
      value is String ? value : fallback;

  static String? _nullableString(Object? value) =>
      value is String && value.isNotEmpty ? value : null;

  static DateTime? _dateTimeFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  Incident copyWith({
    String? title,
    String? description,
    String? category,
    String? location,
    String? status,
    Object? imageUrl = _notProvided,
    List<String>? photoUrls,
    Object? reporterName = _notProvided,
    Object? assignedTo = _notProvided,
  }) {
    final nextImageUrl = !identical(imageUrl, _notProvided)
        ? imageUrl as String?
        : photoUrls != null
            ? (photoUrls.isEmpty ? null : photoUrls.first)
            : this.imageUrl;
    final nextPhotoUrls = photoUrls ??
        (identical(imageUrl, _notProvided)
            ? this.photoUrls
            : (nextImageUrl == null ? <String>[] : <String>[nextImageUrl]));

    return Incident(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      status: status ?? this.status,
      imageUrl: nextImageUrl,
      photoUrls: nextPhotoUrls,
      reportedBy: reportedBy,
      reporterName: identical(reporterName, _notProvided)
          ? this.reporterName
          : reporterName as String?,
      assignedTo: identical(assignedTo, _notProvided)
          ? this.assignedTo
          : assignedTo as String?,
      createdAt: createdAt,
    );
  }
}
