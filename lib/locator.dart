import 'package:enough_mail_app/services/alert_service.dart';
import 'package:enough_mail_app/services/date_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/scaffold_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => MailService());
  locator.registerLazySingleton(() => I18nService());
  locator.registerLazySingleton(() => ScaffoldService());
  locator.registerLazySingleton(() => DateService());
  locator.registerLazySingleton(() => SettingsService());
  locator.registerLazySingleton(() => AlertService());
  locator.registerSingleton(IconService());
}
