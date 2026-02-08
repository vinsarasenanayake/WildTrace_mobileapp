import 'package:flutter/material.dart';
import '../models/photographer.dart';
import '../models/milestone.dart';
import '../services/api/index.dart';
import '../services/database/database_service.dart';

import '../utilities/constants.dart';

class ContentController with ChangeNotifier {
  final ContentApiService _apiService = ContentApiService();
  final DatabaseService _dbService = DatabaseService();
  List<Photographer> _photographers = [];
  List<Milestone> _milestones = [];
  bool _isLoading = false;

  List<Photographer> get photographers => List.unmodifiable(_photographers);
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  bool get isLoading => _isLoading;

  Future<void> fetchContent() async {
    _isLoading = true;
    notifyListeners();

    // try loading from cache
    try {
      final cachedPhotographers = await _dbService.getCachedPhotographers();
      final cachedMilestones = await _dbService.getCachedMilestones();
      if (cachedPhotographers.isNotEmpty || cachedMilestones.isNotEmpty) {
        _photographers = cachedPhotographers;
        _milestones = cachedMilestones;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Content Cache Error: $e');
    }

    try {
      final photographersData = await _apiService.fetchPhotographers();
      _photographers = photographersData.map((data) => Photographer.fromJson(data)).toList();
      await _dbService.cachePhotographers(_photographers);
      
      final milestonesData = await _apiService.fetchMilestones();
      _milestones = milestonesData.map((data) => Milestone.fromJson(data)).toList();
      await _dbService.cacheMilestones(_milestones);
    } catch (e) {
      if (_milestones.isEmpty) {
        _milestones = AppConstants.fallbackMilestones;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
