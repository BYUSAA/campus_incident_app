import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
class IncidentRepository {
  IncidentRepository(this._firestore,this._storage);
  final FirestoreService _firestore; final StorageService _storage;
  Stream<List<Incident>> watchAll()=>_firestore.watchIncidents().map((s)=>s.docs.map((d)=>Incident.fromMap(d.id,d.data())).toList());
  Stream<List<Incident>> watchMine(String uid)=>_firestore.watchMyIncidents(uid).map((s){final list=s.docs.map((d)=>Incident.fromMap(d.id,d.data())).toList();list.sort((a,b)=>(b.createdAt??DateTime(2000)).compareTo(a.createdAt??DateTime(2000)));return list;});
  Future<String> create({required String title,required String description,required String category,required String location,required String uid,required String reporterName,File? photo}) async {
    final urls=<String>[]; if(photo!=null) urls.add(await _storage.uploadIncidentPhoto(file:photo,uid:uid));
    return _firestore.createIncident({'title':title.trim(),'description':description.trim(),'category':category,'location':location.trim(),'reportedBy':uid,'reporterName':reporterName,'status':'Submitted','createdAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp(),'photoUrls':urls,'assignedTo':null});
  }
  Future<Incident?> getById(String id) async {final d=await _firestore.getIncident(id);return d==null?null:Incident.fromMap(id,d);}
  Future<void> updateStatus(String id,String status)=>_firestore.updateIncident(id,{'status':status,'updatedAt':FieldValue.serverTimestamp()});
  Future<void> delete(String id)=>_firestore.deleteIncident(id);
}
