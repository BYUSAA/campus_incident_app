import 'package:cloud_firestore/cloud_firestore.dart';
class Incident {
  const Incident({required this.id,required this.title,required this.description,required this.category,required this.location,required this.reportedBy,required this.reporterName,required this.status,required this.createdAt,this.updatedAt,this.photoUrls=const [],this.assignedTo});
  final String id,title,description,category,location,reportedBy,reporterName,status;
  final DateTime? createdAt,updatedAt;
  final List<String> photoUrls;
  final String? assignedTo;
  factory Incident.fromMap(String id, Map<String,dynamic> m) {
    DateTime? date(dynamic v) => v is Timestamp ? v.toDate() : v is DateTime ? v : null;
    return Incident(id:id,title:m['title'] as String? ?? '',description:m['description'] as String? ?? '',category:m['category'] as String? ?? 'Other',location:m['location'] as String? ?? '',reportedBy:m['reportedBy'] as String? ?? '',reporterName:m['reporterName'] as String? ?? 'Student',status:m['status'] as String? ?? 'Submitted',createdAt:date(m['createdAt']),updatedAt:date(m['updatedAt']),photoUrls:List<String>.from(m['photoUrls'] as List? ?? const []),assignedTo:m['assignedTo'] as String?);
  }
  Map<String,dynamic> toMap() => {'title':title,'description':description,'category':category,'location':location,'reportedBy':reportedBy,'reporterName':reporterName,'status':status,'createdAt':createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!), 'updatedAt':FieldValue.serverTimestamp(),'photoUrls':photoUrls,'assignedTo':assignedTo};
}
