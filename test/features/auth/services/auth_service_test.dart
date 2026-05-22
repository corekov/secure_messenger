import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:secure_messenger/features/auth/services/auth_service.dart';
import 'package:secure_messenger/core/storage/secure_storage_service.dart';

class MockDio extends Mock implements Dio {}
class MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late AuthService authService;
  late MockDio mockDio;
  late MockSecureStorage mockStorage;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockSecureStorage();
    authService = AuthService(mockDio, mockStorage);
  });

  group('AuthService', () {
    test('login successfully saves tokens', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 200,
        data: {
          'access_token': 'test_access',
          'refresh_token': 'test_refresh',
        },
      );

      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => mockResponse);
      when(() => mockStorage.saveAccessToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveRefreshToken(any())).thenAnswer((_) async {});

      await authService.login('user', 'pass');

      verify(() => mockStorage.saveAccessToken('test_access')).called(1);
      verify(() => mockStorage.saveRefreshToken('test_refresh')).called(1);
    });

    test('login throws exception on failure', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 401,
      );

      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => mockResponse);

      expect(authService.login('user', 'pass'), throwsException);
    });

    test('logout clears tokens', () async {
      when(() => mockDio.post(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/auth/logout'),
            statusCode: 200,
          ));
      when(() => mockStorage.clearTokens()).thenAnswer((_) async {});

      await authService.logout();

      verify(() => mockStorage.clearTokens()).called(1);
    });
  });
}
