import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';

/// Whether the signed-in member agreed to share Sandy chats with the
/// third-party AI provider (App Store guideline 5.1.2). Stored per user so a
/// second account on the same device is asked again.
Future<bool> hasSandyAiConsent() async =>
    await sl<ILocalStorage>().getBool(await _key()) ?? false;

Future<void> grantSandyAiConsent() async =>
    sl<ILocalStorage>().setBool(await _key(), value: true);

Future<String> _key() async {
  final userId = await sl<ISecureStorage>().read(StorageKeys.userId);
  return userId == null || userId.isEmpty
      ? StorageKeys.sandyAiConsent
      : '${StorageKeys.sandyAiConsent}_$userId';
}
