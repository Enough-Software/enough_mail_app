import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../models/message.dart';
import '../settings/theme/icon_service.dart';

/// Displays the content of a message in the message overview.
class MessageOverviewContent extends ConsumerWidget {
  /// Creates a new [MessageOverviewContent] widget.
  const MessageOverviewContent({
    super.key,
    required this.message,
    required this.isSentMessage,
  });

  /// The message to display.
  final Message message;

  /// Whether the message is a sent message.
  final bool isSentMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msg = message;
    final mime = msg.mimeMessage;
    final localizations = ref.text;
    final threadSequence = mime.threadSequence;
    final threadLength =
        threadSequence != null ? threadSequence.toList().length : 0;
    final subject = mime.decodeSubject() ?? localizations.subjectUndefined;
    final senderOrRecipients = _getSenderOrRecipients(mime, localizations);
    final hasAttachments = msg.hasAttachment;
    final date = ref.formatDateTime(mime.decodeDate());
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: msg.isFlagged ? theme.colorScheme.secondary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    senderOrRecipients,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontWeight:
                          msg.isSeen ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Text(date, style: const TextStyle(fontSize: 12)),
              if (hasAttachments ||
                  msg.isAnswered ||
                  msg.isForwarded ||
                  msg.isFlagged ||
                  threadLength != 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      if (msg.isFlagged)
                        const Icon(Icons.outlined_flag, size: 12),
                      if (hasAttachments)
                        const Icon(Icons.attach_file, size: 12),
                      if (msg.isAnswered) const Icon(Icons.reply, size: 12),
                      if (msg.isForwarded) const Icon(Icons.forward, size: 12),
                      if (threadLength != 0)
                        IconService.buildNumericIcon(
                          context,
                          threadLength,
                          size: 12,
                        ),
                    ],
                  ),
                ),
            ],
          ),
          Text(
            subject,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: msg.isSeen ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getSenderOrRecipients(
    MimeMessage mime,
    AppLocalizations localizations,
  ) {
    if (isSentMessage) {
      return mime.recipients
          .map((r) => r.hasPersonalName ? r.personalName : r.email)
          .join(', ');
    }
    MailAddress? from;
    from = (mime.from?.isNotEmpty ?? false) ? mime.from?.first : mime.sender;

    return (from?.personalName?.isNotEmpty ?? false)
        ? from?.personalName ?? ''
        : from?.email ?? localizations.emailSenderUnknown;
  }
}
