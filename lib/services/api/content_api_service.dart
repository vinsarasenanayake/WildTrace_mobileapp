import 'base_api_service.dart';

class ContentApiService extends BaseApiService {
  // Fetch photographers from backend
  Future<List<dynamic>> fetchPhotographers() async {
    final data = await get('/photographers');
    return _parseList(data);
  }

  // Fetch milestones from backend
  Future<List<dynamic>> fetchMilestones() async {
    final data = await get('/milestones');
    return _parseList(data);
  }

  List<dynamic> _parseList(dynamic decoded) {
    if (decoded is Map && decoded.containsKey('data')) {
      return decoded['data'];
    } else if (decoded is List) {
      return decoded;
    }
    return [];
  }
}
