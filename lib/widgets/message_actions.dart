import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/contact_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/widgets/recipient_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';

class MessageActions extends StatefulWidget {
  final Message message;
  MessageActions({Key key, @required this.message}) : super(key: key);

  @override
  _MessageActionsState createState() => _MessageActionsState();
}

enum _OverflowMenuChoice {
  reply,
  replyAll,
  forward,
  delete,
  inbox,
  junk,
  seen,
  flag,
  archive,
  redirect,
}

class _MessageActionsState extends State<MessageActions> {
  @override
  void initState() {
    widget.message.addListener(_update);
    super.initState();
  }

  void _update() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.message.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Material(
      elevation: 16,
      child: Row(
        children: [
          if (!widget.message.isEmbedded) ...{
            IconButton(
              icon: Icon(widget.message.isSeen
                  ? Feather.circle // Icons.check_circle_outline
                  : Icons.circle), //Icons.check_circle),
              onPressed: toggleSeen,
            ),
            IconButton(
              icon: Icon(
                  widget.message.isFlagged ? Icons.flag : Icons.outlined_flag),
              onPressed: toggleFlagged,
            ),
          },
          Spacer(),
          IconButton(icon: Icon(Icons.reply), onPressed: reply),
          IconButton(icon: Icon(Icons.reply_all), onPressed: replyAll),
          IconButton(icon: Icon(Icons.forward), onPressed: forward),
          if (widget.message.source.isTrash) ...{
            IconButton(icon: Icon(Entypo.inbox), onPressed: moveToInbox),
          } else if (!widget.message.isEmbedded) ...{
            IconButton(icon: Icon(Icons.delete), onPressed: delete),
          },
          PopupMenuButton<_OverflowMenuChoice>(
            onSelected: onOverflowChoiceSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _OverflowMenuChoice.reply,
                child: ListTile(
                  leading: Icon(Icons.reply),
                  title: Text(localizations.messageActionReply),
                ),
              ),
              PopupMenuItem(
                value: _OverflowMenuChoice.replyAll,
                child: ListTile(
                  leading: Icon(Icons.reply_all),
                  title: Text(localizations.messageActionReplyAll),
                ),
              ),
              PopupMenuItem(
                value: _OverflowMenuChoice.forward,
                child: ListTile(
                  leading: Icon(Icons.forward),
                  title: Text(localizations.messageActionForward),
                ),
              ),
              if (widget.message.source.isTrash) ...{
                PopupMenuItem(
                  value: _OverflowMenuChoice.inbox,
                  child: ListTile(
                    leading: Icon(Entypo.inbox),
                    title: Text(localizations.messageActionMoveToInbox),
                  ),
                ),
              } else if (!widget.message.isEmbedded) ...{
                PopupMenuItem(
                  value: _OverflowMenuChoice.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text(localizations.messageActionDelete),
                  ),
                ),
              },
              if (!widget.message.isEmbedded) ...{
                PopupMenuDivider(),
                PopupMenuItem(
                  value: _OverflowMenuChoice.seen,
                  child: ListTile(
                    leading: Icon(
                        widget.message.isSeen ? Feather.circle : Icons.circle),
                    title: Text(
                      widget.message.isSeen
                          ? localizations.messageStatusSeen
                          : localizations.messageStatusUnseen,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: _OverflowMenuChoice.flag,
                  child: ListTile(
                    leading: Icon(widget.message.isFlagged
                        ? Icons.flag
                        : Icons.outlined_flag),
                    title: Text(
                      widget.message.isFlagged
                          ? localizations.messageStatusFlagged
                          : localizations.messageStatusUnflagged,
                    ),
                  ),
                ),
                if (widget.message.source.supportsMessageFolders) ...{
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: _OverflowMenuChoice.junk,
                    child: ListTile(
                      leading: Icon(widget.message.source.isJunk
                          ? Entypo.check
                          : Entypo.bug),
                      title: Text(
                        widget.message.source.isJunk
                            ? localizations.messageActionMarkAsNotJunk
                            : localizations.messageActionMarkAsJunk,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: _OverflowMenuChoice.archive,
                    child: ListTile(
                      leading: Icon(widget.message.source.isArchive
                          ? Entypo.inbox
                          : Entypo.archive),
                      title: Text(
                        widget.message.source.isArchive
                            ? localizations.messageActionUnarchive
                            : localizations.messageActionArchive,
                      ),
                    ),
                  ),
                },
                PopupMenuItem(
                  value: _OverflowMenuChoice.redirect,
                  child: ListTile(
                    leading: Icon(Icons.compare_arrows),
                    title: Text(
                      localizations.messageActionRedirect,
                    ),
                  ),
                ),
              },
            ],
          ),
        ],
      ),
    );
  }

  void onOverflowChoiceSelected(_OverflowMenuChoice result) {
    switch (result) {
      case _OverflowMenuChoice.reply:
        reply();
        break;
      case _OverflowMenuChoice.replyAll:
        replyAll();
        break;
      case _OverflowMenuChoice.forward:
        forward();
        break;
      case _OverflowMenuChoice.delete:
        delete();
        break;
      case _OverflowMenuChoice.inbox:
        moveToInbox();
        break;
      case _OverflowMenuChoice.seen:
        toggleSeen();
        break;
      case _OverflowMenuChoice.flag:
        toggleFlagged();
        break;
      case _OverflowMenuChoice.junk:
        moveJunk();
        break;
      case _OverflowMenuChoice.archive:
        moveArchive();
        break;
      case _OverflowMenuChoice.redirect:
        redirectMessage();
        break;
    }
  }

  void next() {
    navigateToMessage(widget.message.next);
  }

  void previous() {
    navigateToMessage(widget.message.previous);
  }

  void navigateToMessage(Message message) {
    if (message != null) {
      locator<NavigationService>()
          .push(Routes.mailDetails, arguments: message, replace: true);
    }
  }

  void replyAll() {
    reply(all: true);
  }

  void reply({all = false}) {
    final account = widget.message.mailClient.account;

    final builder = MessageBuilder.prepareReplyToMessage(
        widget.message.mimeMessage, account.fromAddress,
        aliases: account.aliases,
        quoteOriginalText: false,
        handlePlusAliases: account.supportsPlusAliases ?? false,
        replyAll: all);
    navigateToCompose(widget.message, builder, ComposeAction.answer);
  }

  void redirectMessage() async {
    final mailClient = widget.message.mailClient;
    final account = locator<MailService>().getAccountFor(mailClient.account);
    if (account.contactManager == null) {
      await locator<ContactService>().getForAccount(account);
    }

    final List<MailAddress> recipients = [];
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final redirect = await DialogHelper.showWidgetDialog(
      context,
      localizations.redirectTitle,
      SingleChildScrollView(
        child: SizedBox(
          width: size.width - 32,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.redirectInfo,
                  style: Theme.of(context).textTheme.caption),
              RecipientInputField(
                addresses: recipients,
                contactManager: account.contactManager,
                labelText: localizations.detailsHeaderTo,
                hintText: localizations.composeRecipientHint,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(localizations.actionCancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(localizations.messageActionRedirect),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (redirect == true && recipients.isNotEmpty) {
      final mime = widget.message.mimeMessage;
      if (mime.mimeData == null) {
        // download complete message first
        await mailClient.fetchMessageContents(mime);
      }
      try {
        mailClient.sendMessage(mime,
            recipients: recipients, appendToSent: false);
        locator<ScaffoldMessengerService>()
            .showTextSnackBar(localizations.resultRedirectedSuccess);
      } catch (e, s) {
        print('message could not get redirected: $e $s');
        locator<ScaffoldMessengerService>()
            .showTextSnackBar(localizations.resultRedirectedFailure);
      }
    }
  }

  void delete() async {
    locator<NavigationService>().pop();
    await widget.message.source.deleteMessage(widget.message);
    locator<NotificationService>()
        .cancelNotificationForMailMessage(widget.message);
  }

  void moveJunk() async {
    final source = widget.message.source;
    if (source.isJunk) {
      await source.markAsNotJunk(widget.message);
    } else {
      locator<NotificationService>()
          .cancelNotificationForMailMessage(widget.message);
      await source.markAsJunk(widget.message);
    }
    locator<NavigationService>().pop();
  }

  void moveToInbox() async {
    final source = widget.message.source;
    source.moveMessage(widget.message, MailboxFlag.inbox,
        locator<I18nService>().localizations.resultMovedToInbox);
    locator<NavigationService>().pop();
  }

  void moveArchive() async {
    final source = widget.message.source;
    if (source.isArchive) {
      await source.moveToInbox(widget.message);
    } else {
      locator<NotificationService>()
          .cancelNotificationForMailMessage(widget.message);
      await source.archive(widget.message);
    }
    locator<NavigationService>().pop();
  }

  void forward() {
    var from = widget.message.mailClient.account.fromAddress;
    var builder = MessageBuilder.prepareForwardMessage(
      widget.message.mimeMessage,
      from: from,
      quoteMessage: false,
    );
    navigateToCompose(widget.message, builder, ComposeAction.forward);
  }

  void toggleFlagged() async {
    final msg = widget.message;
    final flagged = !msg.isFlagged;
    await msg.source.markAsFlagged(msg, flagged);
  }

  void toggleSeen() async {
    final msg = widget.message;
    final seen = !msg.isSeen;
    await msg.source.markAsSeen(msg, seen);
  }

  void navigateToCompose(
      Message message, MessageBuilder builder, ComposeAction action) {
    final data = ComposeData(message, builder, action);
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: data, replace: true);
  }
}
