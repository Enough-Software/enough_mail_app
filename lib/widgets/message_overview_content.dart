import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';

import '../locator.dart';

class MessageOverviewContent extends StatelessWidget {
  final Message message;
  final bool isSentMessage;

  const MessageOverviewContent({
    Key? key,
    required this.message,
    required this.isSentMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final msg = message;
    final mime = msg.mimeMessage;
    final localizations = AppLocalizations.of(context)!;
    final threadLength =
        mime.threadSequence != null ? mime.threadSequence!.toList().length : 0;
    final subject = mime.decodeSubject() ?? localizations.subjectUndefined;
    final senderOrRecipients = _getSenderOrRecipients(mime, localizations);
    final hasAttachments = msg.hasAttachment;
    final date = locator<I18nService>().formatDateTime(mime.decodeDate());
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    senderOrRecipients,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                        fontWeight:
                            msg.isSeen ? FontWeight.normal : FontWeight.bold),
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
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      if (msg.isFlagged)
                        const Icon(Icons.outlined_flag, size: 12),
                      if (hasAttachments)
                        const Icon(Icons.attach_file, size: 12),
                      if (msg.isAnswered) const Icon(Icons.reply, size: 12),
                      if (msg.isForwarded) const Icon(Icons.forward, size: 12),
                      if (threadLength != 0)
                        IconService.buildNumericIcon(context, threadLength,
                            size: 12.0),
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
                fontWeight: msg.isSeen ? FontWeight.normal : FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getSenderOrRecipients(
      MimeMessage mime, AppLocalizations localizations) {
    if (isSentMessage) {
      return mime.recipients
          .map((r) => r.hasPersonalName ? r.personalName : r.email)
          .join(', ');
    }
    MailAddress? from;
    if (mime.from?.isNotEmpty ?? false) {
      from = mime.from!.first;
    } else {
      from = mime.sender;
    }
    return (from?.personalName?.isNotEmpty ?? false)
        ? from!.personalName!
        : from?.email != null
            ? from!.email
            : localizations.emailSenderUnknown;
  }
}
