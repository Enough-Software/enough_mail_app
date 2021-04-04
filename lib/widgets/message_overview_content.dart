import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../locator.dart';

class MessageOverviewContent extends StatelessWidget {
  final Message message;
  const MessageOverviewContent({Key key, @required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final threadLength = message.mimeMessage.threadSequence != null
        ? message.mimeMessage.threadSequence.toList().length
        : 0;
    final mime = message.mimeMessage;
    final subject = mime.decodeSubject() ?? localizations.subjectUndefined;
    MailAddress from;
    if (mime.from?.isNotEmpty ?? false) {
      from = mime.from.first;
    } else {
      from = mime.sender;
    }
    final sender = (from?.personalName?.isNotEmpty ?? false)
        ? from.personalName
        : from?.email != null
            ? from.email
            : localizations.emailSenderUnknown;
    final hasAttachments = mime.hasAttachments();
    final date = locator<I18nService>().formatDate(mime.decodeDate());
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: message.isFlagged ? Colors.amber[50] : null,
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
                    sender,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                        fontWeight: message.isSeen
                            ? FontWeight.normal
                            : FontWeight.bold),
                  ),
                ),
              ),
              Text(date, style: TextStyle(fontSize: 12)),
              if (hasAttachments ||
                  message.isAnswered ||
                  message.isForwarded ||
                  message.isFlagged ||
                  threadLength != null) ...{
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      if (message.isFlagged) ...{
                        Icon(Icons.outlined_flag, size: 12),
                      },
                      if (hasAttachments) ...{
                        Icon(Icons.attach_file, size: 12),
                      },
                      if (message.isAnswered) ...{
                        Icon(Icons.reply, size: 12),
                      },
                      if (message.isForwarded) ...{
                        Icon(Icons.forward, size: 12),
                      },
                      if (threadLength != 0) ...{
                        IconService.buildNumericIcon(threadLength, size: 12.0),
                      },
                    ],
                  ),
                ),
              }
            ],
          ),
          Text(
            subject,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight:
                    message.isSeen ? FontWeight.normal : FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
