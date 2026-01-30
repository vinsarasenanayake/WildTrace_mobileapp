// Imports
import 'package:flutter/material.dart';
import '../models/photographer.dart';
import '../models/milestone.dart';
import '../services/api_service.dart';

// Content Provider
class ContentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Photographer> _photographers = [];
  List<Milestone> _milestones = [];
  bool _isLoading = false;

  List<Photographer> get photographers => List.unmodifiable(_photographers);
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  bool get isLoading => _isLoading;

  // Fetch Content
  Future<void> fetchContent() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final photographersData = await _apiService.fetchPhotographers();
      _photographers = photographersData.map((data) => Photographer.fromJson(data)).toList();
      
      final milestonesData = await _apiService.fetchMilestones();
      _milestones = milestonesData.map((data) => Milestone.fromJson(data)).toList();
      
    } catch (e) {
      debugPrint('Error fetching content: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
