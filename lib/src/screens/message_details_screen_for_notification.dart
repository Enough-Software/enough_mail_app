import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../mail/provider.dart';
import '../notification/model.dart';
import 'error_screen.dart';
import 'message_details_screen.dart';

/// Displays the message details for a notification
class MessageDetailsForNotificationScreen extends ConsumerWidget {
  /// Creates a [MessageDetailsForNotificationScreen]
  const MessageDetailsForNotificationScreen({
    super.key,
    required this.payload,
    this.blockExternalContent = false,
  });

  /// The payload of the notification
  final MailNotificationPayload payload;

  /// Whether to block external content
  final bool blockExternalContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageValue = ref.watch(
      singleMessageLoaderProvider(payload: payload),
    );

    return messageValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorScreen(error: error, stackTrace: stack),
      data: (data) => MessageDetailsScreen(
        message: data,
        blockExternalContent: blockExternalContent,
      ),
    );
  }
}
