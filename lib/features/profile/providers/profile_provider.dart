import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';

part 'profile_provider.g.dart';

class UserProfile {
  final String id;
  final String username;

  UserProfile({required this.id, required this.username});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
    );
  }
}

@riverpod
Future<UserProfile?> profile(Ref ref) async {
  final isAuthenticated = ref.watch(authProvider);
  if (!isAuthenticated) return null;

  final dio = ref.watch(dioClientProvider);

  try {
    final response = await dio.get('/auth/me');
    if (response.statusCode == 200) {
      return UserProfile.fromJson(response.data);
    }
    return null;
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      ref.read(authProvider.notifier).forceLogout();
    }
    throw Exception('Failed to load profile');
  }
}
