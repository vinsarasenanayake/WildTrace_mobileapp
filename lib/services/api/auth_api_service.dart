import 'base_api_service.dart';

// auth api service
class AuthApiService extends BaseApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/login', body: {
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
    });

    if (response['user'] != null) {
      final userData = response['user'];
      final bool isAdmin =
          userData['role']?.toString().toLowerCase() == 'admin' ||
          userData['role_id']?.toString() == '1' ||
          userData['is_admin'] == true ||
          userData['is_admin']?.toString() == '1';
      if (isAdmin) {
        throw Exception('Admin dashboard access restricted to web platform.');
      }
    }
    return response;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post('/register', body: userData);
  }

  Future<void> logout(String token) async {
    try {
      await post('/logout', token: token);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    return await get('/user', token: token);
  }

  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
    String token,
  ) async {
    return await put('/user/profile', body: profileData, token: token);
  }
}
