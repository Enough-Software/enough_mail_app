import 'package:get_it/get_it.dart';

import 'notification/service.dart';
import 'services/app_service.dart';
import 'services/biometrics_service.dart';
import 'services/date_service.dart';
import 'services/i18n_service.dart';
import 'services/icon_service.dart';
import 'services/key_service.dart';
import 'services/location_service.dart';
import 'services/providers.dart';
import 'services/scaffold_messenger_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator
    ..registerLazySingleton(I18nService.new)
    ..registerLazySingleton(ScaffoldMessengerService.new)
    ..registerLazySingleton(DateService.new)
    ..registerSingleton(IconService())
    ..registerLazySingleton(() => NotificationService.instance)
    ..registerLazySingleton(AppService.new)
    ..registerLazySingleton(LocationService.new)
    ..registerLazySingleton(KeyService.new)
    ..registerLazySingleton(ProviderService.new)
    ..registerLazySingleton(BiometricsService.new);
}
