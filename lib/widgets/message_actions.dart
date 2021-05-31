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
import 'package:enough_mail_app/util/validator.dart';
import 'package:enough_mail_app/widgets/recipient_input_field.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import 'button_text.dart';
import 'mailbox_tree.dart';

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
  forwardAsAttachment,
  forwardAttachments,
  delete,
  inbox,
  seen,
  flag,
  move,
  junk,
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
    final attachments = widget.message.attachments;
    return PlatformBottomBar(
      cupertinoBackgroundOpacity: 0.8,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!widget.message.isEmbedded) ...{
              PlatformIconButton(
                icon: Icon(widget.message.isSeen
                    ? Feather.circle // Icons.check_circle_outline
                    : Icons.circle), //Icons.check_circle),
                onPressed: toggleSeen,
              ),
              PlatformIconButton(
                icon: Icon(widget.message.isFlagged
                    ? Icons.flag
                    : Icons.outlined_flag),
                onPressed: toggleFlagged,
              ),
            },
            Spacer(),
            PlatformIconButton(icon: Icon(Icons.reply), onPressed: reply),
            PlatformIconButton(
                icon: Icon(Icons.reply_all), onPressed: replyAll),
            PlatformIconButton(icon: Icon(Icons.forward), onPressed: forward),
            if (widget.message.source.isTrash) ...{
              PlatformIconButton(
                  icon: Icon(Entypo.inbox), onPressed: moveToInbox),
            } else if (!widget.message.isEmbedded) ...{
              PlatformIconButton(icon: Icon(Icons.delete), onPressed: delete),
            },
            PlatformPopupMenuButton<_OverflowMenuChoice>(
              onSelected: onOverflowChoiceSelected,
              itemBuilder: (context) => [
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.reply,
                  child: PlatformListTile(
                    leading: Icon(Icons.reply),
                    title: Text(localizations.messageActionReply),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.replyAll,
                  child: PlatformListTile(
                    leading: Icon(Icons.reply_all),
                    title: Text(localizations.messageActionReplyAll),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.forward,
                  child: PlatformListTile(
                    leading: Icon(Icons.forward),
                    title: Text(localizations.messageActionForward),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.forwardAsAttachment,
                  child: PlatformListTile(
                    leading: Icon(Icons.forward_to_inbox),
                    title: Text(localizations.messageActionForwardAsAttachment),
                  ),
                ),
                if (attachments.isNotEmpty) ...{
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.forwardAttachments,
                    child: PlatformListTile(
                      leading: Icon(Icons.attach_file),
                      title: Text(localizations
                          .messageActionForwardAttachments(attachments.length)),
                    ),
                  ),
                },
                if (widget.message.source.isTrash) ...{
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.inbox,
                    child: PlatformListTile(
                      leading: Icon(Entypo.inbox),
                      title: Text(localizations.messageActionMoveToInbox),
                    ),
                  ),
                } else if (!widget.message.isEmbedded) ...{
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.delete,
                    child: PlatformListTile(
                      leading: Icon(Icons.delete),
                      title: Text(localizations.messageActionDelete),
                    ),
                  ),
                },
                if (!widget.message.isEmbedded) ...{
                  PlatformPopupDivider(),
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.seen,
                    child: PlatformListTile(
                      leading: Icon(widget.message.isSeen
                          ? Feather.circle
                          : Icons.circle),
                      title: Text(
                        widget.message.isSeen
                            ? localizations.messageStatusSeen
                            : localizations.messageStatusUnseen,
                      ),
                    ),
                  ),
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.flag,
                    child: PlatformListTile(
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
                    PlatformPopupDivider(),
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.move,
                      child: PlatformListTile(
                        leading: Icon(MaterialCommunityIcons.file_move),
                        title: Text(localizations.messageActionMove),
                      ),
                    ),
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.junk,
                      child: PlatformListTile(
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
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.archive,
                      child: PlatformListTile(
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
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.redirect,
                    child: PlatformListTile(
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
      case _OverflowMenuChoice.forwardAsAttachment:
        forwardAsAttachment();
        break;
      case _OverflowMenuChoice.forwardAttachments:
        forwardAttachments();
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
      case _OverflowMenuChoice.move:
        move();
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
    final textEditingController = TextEditingController();
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
                controller: textEditingController,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: ButtonText(localizations.actionCancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: ButtonText(localizations.messageActionRedirect),
          onPressed: () {
            if (Validator.validateEmail(textEditingController.text)) {
              recipients.add(MailAddress(null, textEditingController.text));
            }
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
    if (redirect == true) {
      if (recipients.isEmpty) {
        await DialogHelper.showTextDialog(context, localizations.errorTitle,
            localizations.redirectEmailInputRequired);
      } else {
        final mime = widget.message.mimeMessage;
        if (mime.mimeData == null) {
          // download complete message first
          await mailClient.fetchMessageContents(mime);
        }
        try {
          await mailClient.sendMessage(mime,
              recipients: recipients, appendToSent: false);
          locator<ScaffoldMessengerService>()
              .showTextSnackBar(localizations.resultRedirectedSuccess);
        } catch (e, s) {
          print('message could not get redirected: $e $s');
          await DialogHelper.showTextDialog(context, localizations.errorTitle,
              localizations.resultRedirectedFailure(e.message));
        }
      }
    }
  }

  void delete() async {
    locator<NavigationService>().pop();
    await widget.message.source.deleteMessage(widget.message);
    locator<NotificationService>()
        .cancelNotificationForMailMessage(widget.message);
  }

  void move() {
    final localizations = locator<I18nService>().localizations;
    DialogHelper.showWidgetDialog(
      context,
      localizations.moveTitle,
      SingleChildScrollView(
        child: MailboxTree(
          account: widget.message.account,
          onSelected: moveTo,
          current: widget.message.mailClient.selectedMailbox,
        ),
      ),
      defaultActions: DialogActions.cancel,
    );
  }

  void moveTo(Mailbox mailbox) async {
    locator<NavigationService>().pop(); // alert
    locator<NavigationService>().pop(); // detail view
    final localizations = locator<I18nService>().localizations;
    final message = widget.message;
    final source = message.source;
    await source.moveMessage(
        message, mailbox, localizations.moveSuccess(mailbox.name));
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
    source.moveMessageToFlag(widget.message, MailboxFlag.inbox,
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
    final from = widget.message.mailClient.account.fromAddress;
    final builder = MessageBuilder.prepareForwardMessage(
      widget.message.mimeMessage,
      from: from,
      quoteMessage: false,
    );
    final composeFuture = addAttachments(widget.message, builder);
    navigateToCompose(
        widget.message, builder, ComposeAction.forward, composeFuture);
  }

  void forwardAsAttachment() async {
    final message = widget.message;
    final mailClient = message.mailClient;
    final from = mailClient.account.fromAddress;
    var mime = message.mimeMessage;
    final builder = MessageBuilder();
    builder.from = [from];

    builder.subject = MessageBuilder.createForwardSubject(mime.decodeSubject());
    Future composeFuture;
    if (mime.mimeData == null) {
      composeFuture = mailClient.fetchMessageContents(mime).then((value) {
        message.updateMime(value);
        builder.addMessagePart(value);
      });
    } else {
      builder.addMessagePart(mime);
    }
    navigateToCompose(
        widget.message, builder, ComposeAction.forward, composeFuture);
  }

  void forwardAttachments() async {
    final message = widget.message;
    final mailClient = message.mailClient;
    final from = mailClient.account.fromAddress;
    var mime = message.mimeMessage;
    final builder = MessageBuilder();
    builder.from = [from];
    builder.subject = MessageBuilder.createForwardSubject(mime.decodeSubject());
    final composeFuture = addAttachments(message, builder);
    navigateToCompose(message, builder, ComposeAction.forward, composeFuture);
  }

  Future addAttachments(Message message, MessageBuilder builder) {
    final attachments = message.attachments;
    final mailClient = message.mailClient;
    var mime = message.mimeMessage;
    Future composeFuture;
    if (mime.mimeData == null && attachments.length > 1) {
      composeFuture = mailClient.fetchMessageContents(mime).then((value) {
        message.updateMime(value);
        for (final attachment in attachments) {
          var part = value.getPart(attachment.fetchId);
          builder.addPart(mimePart: part);
        }
      });
    } else {
      final futures = <Future>[];
      for (final attachment in message.attachments) {
        final part = mime.getPart(attachment.fetchId);
        if (part != null) {
          builder.addPart(mimePart: part);
        } else {
          futures.add(mailClient
              .fetchMessagePart(mime, attachment.fetchId)
              .then((value) {
            builder.addPart(mimePart: value);
          }));
        }
        composeFuture = futures.isEmpty ? null : Future.wait(futures);
      }
    }
    return composeFuture;
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
      Message message, MessageBuilder builder, ComposeAction action,
      [Future composeFuture]) {
    final data = ComposeData([message], builder, action, future: composeFuture);
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: data, replace: true);
  }
}
