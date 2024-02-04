import 'package:logger/logger.dart';

/// Global logger
final logger = Logger(
  level: Level.debug,
  output: ConsoleOutput(),
  printer: PrettyPrinter(),
);
