import 'package:get_it/get_it.dart';

import 'models/async_mime_source_factory.dart';
import 'services/app_service.dart';
import 'services/background_service.dart';
import 'services/biometrics_service.dart';
import 'services/contact_service.dart';
import 'services/date_service.dart';
import 'services/i18n_service.dart';
import 'services/icon_service.dart';
import 'services/key_service.dart';
import 'services/location_service.dart';
import 'services/mail_service.dart';
import 'services/navigation_service.dart';
import 'services/notification_service.dart';
import 'services/providers.dart';
import 'services/scaffold_messenger_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator
    ..registerLazySingleton(NavigationService.new)
    ..registerLazySingleton(
      () => MailService(
        mimeSourceFactory:
            const AsyncMimeSourceFactory(isOfflineModeSupported: false),
      ),
    )
    ..registerLazySingleton(I18nService.new)
    ..registerLazySingleton(ScaffoldMessengerService.new)
    ..registerLazySingleton(DateService.new)
    ..registerSingleton(IconService())
    ..registerLazySingleton(NotificationService.new)
    ..registerLazySingleton(BackgroundService.new)
    ..registerLazySingleton(AppService.new)
    ..registerLazySingleton(LocationService.new)
    ..registerLazySingleton(ContactService.new)
    ..registerLazySingleton(KeyService.new)
    ..registerLazySingleton(ProviderService.new)
    ..registerLazySingleton(BiometricsService.new);
}
