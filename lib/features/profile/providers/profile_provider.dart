import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';

part 'profile_provider.g.dart';

class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;

  UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
  });

  UserProfile copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? bio,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
    );
  }
}

@riverpod
class Profile extends _$Profile {
  @override
  FutureOr<UserProfile?> build() async {
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

  Future<void> updateBio(String newBio) async {
    final dio = ref.read(dioClientProvider);
    try {
      await dio.put('/auth/me/bio', data: {'bio': newBio});
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(bio: newBio));
      }
    } catch (e) {
      throw Exception('Failed to update bio: $e');
    }
  }

  Future<void> uploadAvatar(File imageFile) async {
    final dio = ref.read(dioClientProvider);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: 'avatar.jpg'),
      });
      final response = await dio.post('/auth/me/avatar', data: formData);
      if (response.statusCode == 200 && response.data['avatar_url'] != null) {
        if (state.value != null) {
          state = AsyncValue.data(state.value!.copyWith(avatarUrl: response.data['avatar_url']));
        }
      }
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
