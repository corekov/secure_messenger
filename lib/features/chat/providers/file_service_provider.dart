import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../services/file_service.dart';

part 'file_service_provider.g.dart';

@riverpod
FileService fileService(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return FileService(dio);
}
