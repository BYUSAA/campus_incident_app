import 'package:cloud_firestore/cloud_firestore.dart';

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
      'imageUrl': imageUrl ?? (images.isEmpty ? null : images.first),
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
        ? rawImages.whereType<String>().toList(growable: false)
        : <String>[];
    final legacyImage = map['imageUrl'] as String?;
    return Incident(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? 'Submitted',
      imageUrl: legacyImage ?? (images.isEmpty ? null : images.first),
      photoUrls: images.isEmpty && legacyImage != null ? [legacyImage] : images,
      reportedBy: map['reportedBy'] as String? ?? '',
      reporterName: map['reporterName'] as String?,
      assignedTo: map['assignedTo'] as String?,
      createdAt: _dateTimeFrom(map['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

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
    String? imageUrl,
    List<String>? photoUrls,
    String? reporterName,
    String? assignedTo,
  }) {
    return Incident(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      reportedBy: reportedBy,
      reporterName: reporterName ?? this.reporterName,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
    );
  }
}
