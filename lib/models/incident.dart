import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status; // Submitted, In Progress, Resolved
  final String? imageUrl;
  final String reportedBy;
  final DateTime createdAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    this.imageUrl,
    required this.reportedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'status': status,
        'imageUrl': imageUrl,
        'reportedBy': reportedBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Incident.fromMap(String id, Map<String, dynamic> map) => Incident(
        id: id,
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        category: map['category'] ?? '',
        location: map['location'] ?? '',
        status: map['status'] ?? 'Submitted',
        imageUrl: map['imageUrl'],
        reportedBy: map['reportedBy'] ?? '',
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}