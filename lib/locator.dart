import 'package:enough_mail_app/models/async_mime_source_factory.dart';
import 'package:enough_mail_app/services/biometrics_service.dart';
import 'package:enough_mail_app/services/providers.dart';
import 'package:enough_mail_app/services/app_service.dart';
import 'package:enough_mail_app/services/background_service.dart';
import 'package:enough_mail_app/services/contact_service.dart';
import 'package:enough_mail_app/services/date_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/key_service.dart';
import 'package:enough_mail_app/services/location_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/services/theme_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(
    () => MailService(
      mimeSourceFactory:
          const AsyncMimeSourceFactory(isOfflineModeSupported: true),
    ),
  );
  locator.registerLazySingleton(() => I18nService());
  locator.registerLazySingleton(() => ScaffoldMessengerService());
  locator.registerLazySingleton(() => DateService());
  locator.registerLazySingleton(() => SettingsService());
  locator.registerSingleton(IconService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => BackgroundService());
  locator.registerLazySingleton(() => AppService());
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => ContactService());
  locator.registerLazySingleton(() => KeyService());
  locator.registerLazySingleton(() => ProviderService());
  locator.registerLazySingleton(() => BiometricsService());
}
