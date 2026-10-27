import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';
class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._repo); final IncidentRepository _repo;
  StreamSubscription<List<Incident>>? _sub; List<Incident> _all=[]; bool _loading=false; String? _error; String _query=''; String _category='All'; String _status='All';
  String get selectedCategory=>_category; String get selectedStatus=>_status; bool get isLoading=>_loading; String? get error=>_error;
  List<Incident> get incidents=>_all.where((i){final q=_query.toLowerCase();return (_category=='All'||i.category==_category)&&(_status=='All'||i.status==_status)&&(q.isEmpty||i.title.toLowerCase().contains(q)||i.description.toLowerCase().contains(q)||i.location.toLowerCase().contains(q));}).toList();
  void subscribeToIncidents(){_sub?.cancel();_loading=true;notifyListeners();_sub=_repo.watchAll().listen((v){_all=v;_loading=false;_error=null;notifyListeners();},onError:(Object e){_error=e.toString();_loading=false;notifyListeners();});}
  void setSearch(String v){_query=v;notifyListeners();} void setCategory(String v){_category=v;notifyListeners();} void setStatus(String v){_status=v;notifyListeners();}
  Future<String?> createIncident({required String title,required String description,required String category,required String location,required String uid,required String reporterName,File? photo}) async { _loading=true;notifyListeners();try{return await _repo.create(title:title,description:description,category:category,location:location,uid:uid,reporterName:reporterName,photo:photo);}catch(e){_error=e.toString();rethrow;}finally{_loading=false;notifyListeners();}}
  Future<void> updateStatus(String id,String status)=>_repo.updateStatus(id,status); Future<void> deleteIncident(String id)=>_repo.delete(id); Future<Incident?> getById(String id)=>_repo.getById(id);
  @override void dispose(){_sub?.cancel();super.dispose();}
}
