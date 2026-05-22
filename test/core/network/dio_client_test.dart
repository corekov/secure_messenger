import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:secure_messenger/core/network/dio_client.dart';
import 'package:secure_messenger/core/storage/secure_storage_service.dart';
import 'package:secure_messenger/features/auth/providers/auth_provider.dart';

class MockSecureStorage extends Mock implements SecureStorageService {}
class MockAuthProvider extends Mock implements Auth {}
class MockDio extends Mock implements Dio {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late AuthInterceptor interceptor;
  late MockSecureStorage mockStorage;
  late MockAuthProvider mockAuthProvider;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(DioException(requestOptions: RequestOptions(path: '')));
  });

  setUp(() {
    mockStorage = MockSecureStorage();
    mockAuthProvider = MockAuthProvider();
    mockDio = MockDio();

    when(() => mockDio.options).thenReturn(BaseOptions(baseUrl: 'http://test'));

    interceptor = AuthInterceptor(mockStorage, mockAuthProvider, mockDio);
  });

  group('AuthInterceptor', () {
    test('onRequest adds token to headers if available', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => 'test_token');
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test_token');
      verify(() => handler.next(options)).called(1);
    });

    test('onError calls next if status is not 401', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 400),
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
    });
  });
}
