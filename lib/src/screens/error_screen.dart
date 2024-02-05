import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../logger.dart';
import 'base.dart';

/// Displays details about an error
class ErrorScreen extends ConsumerWidget {
  /// Creates an [ErrorScreen]
  ErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
    this.message,
  }) {
    logger.e(
      '${message ?? 'ErrorScreen'}: $error',
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// The error
  final Object error;

  /// The optional error message
  final String? message;

  /// The optional stack trace
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context, WidgetRef ref) => BasePage(
        title: ref.text.errorTitle,
        content: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SelectableText(message ?? '$error'),
          ),
        ),
      );
}
