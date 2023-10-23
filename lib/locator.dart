import 'package:get_it/get_it.dart';

import 'services/app_service.dart';
import 'services/biometrics_service.dart';
import 'services/location_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator
    ..registerLazySingleton(AppService.new)
    ..registerLazySingleton(LocationService.new)
    ..registerLazySingleton(BiometricsService.new);
}
