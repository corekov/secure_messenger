import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';

part 'user_service.g.dart';

class UserService {
  final Dio _dio;

  const UserService(this._dio);

  Future<void> uploadKeys({
    required String identityKey,
    required String signedPrekey,
    required String prekeySig,
    required List<String> oneTimeKeys,
  }) async {
    await _dio.post(
      '/users/keys',
      data: {
        'identity_key': identityKey,
        'signed_prekey': signedPrekey,
        'prekey_sig': prekeySig,
        'one_time_keys': oneTimeKeys,
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final response = await _dio.get(
      '/users/search',
      queryParameters: {'q': query},
    );
    final data = response.data as List;
    return data.cast<Map<String, dynamic>>();
  }
}

@riverpod
UserService userService(Ref ref) {
  return UserService(ref.watch(dioClientProvider));
}
