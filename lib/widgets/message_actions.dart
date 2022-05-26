import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/contact_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/util/validator.dart';
import 'package:enough_mail_app/widgets/icon_text.dart';
import 'package:enough_mail_app/widgets/recipient_input_field.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'button_text.dart';
import 'mailbox_tree.dart';

class MessageActions extends StatefulWidget {
  const MessageActions({Key? key, required this.message}) : super(key: key);
  final Message message;

  @override
  State<MessageActions> createState() => _MessageActionsState();
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
  addNotification,
}

class _MessageActionsState extends State<MessageActions> {
  @override
  void initState() {
    widget.message.addListener(_update);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MessageActions oldWidget) {
    oldWidget.message.removeListener(_update);
    widget.message.addListener(_update);
    super.didUpdateWidget(oldWidget);
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
    final iconService = locator<IconService>();
    return PlatformBottomBar(
      cupertinoBackgroundOpacity: 0.8,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!widget.message.isEmbedded) ...[
              DensePlatformIconButton(
                icon: Icon(iconService.getMessageIsSeen(widget.message.isSeen)),
                onPressed: _toggleSeen,
              ),
              DensePlatformIconButton(
                icon: Icon(
                    iconService.getMessageIsFlagged(widget.message.isFlagged)),
                onPressed: _toggleFlagged,
              ),
            ],
            const Spacer(),
            DensePlatformIconButton(
              icon: Icon(iconService.messageActionReply),
              onPressed: _reply,
            ),
            DensePlatformIconButton(
              icon: Icon(iconService.messageActionReplyAll),
              onPressed: _replyAll,
            ),
            DensePlatformIconButton(
              icon: Icon(iconService.messageActionForward),
              onPressed: _forward,
            ),
            if (widget.message.source.isTrash)
              DensePlatformIconButton(
                icon: Icon(iconService.messageActionMoveToInbox),
                onPressed: _moveToInbox,
              )
            else if (!widget.message.isEmbedded)
              DensePlatformIconButton(
                icon: Icon(iconService.messageActionDelete),
                onPressed: _delete,
              ),
            PlatformPopupMenuButton<_OverflowMenuChoice>(
              onSelected: _onOverflowChoiceSelected,
              itemBuilder: (context) => [
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.reply,
                  child: IconText(
                    icon: Icon(iconService.messageActionReply),
                    label: Text(localizations!.messageActionReply),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.replyAll,
                  child: IconText(
                    icon: Icon(iconService.messageActionReplyAll),
                    label: Text(localizations.messageActionReplyAll),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.forward,
                  child: IconText(
                    icon: Icon(iconService.messageActionForward),
                    label: Text(localizations.messageActionForward),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _OverflowMenuChoice.forwardAsAttachment,
                  child: IconText(
                    icon: Icon(iconService.messageActionForwardAsAttachment),
                    label: Text(localizations.messageActionForwardAsAttachment),
                  ),
                ),
                if (attachments.isNotEmpty)
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.forwardAttachments,
                    child: IconText(
                      icon: Icon(iconService.messageActionForwardAttachments),
                      label: Text(localizations
                          .messageActionForwardAttachments(attachments.length)),
                    ),
                  ),
                if (widget.message.source.isTrash)
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.inbox,
                    child: IconText(
                      icon: Icon(iconService.messageActionMoveToInbox),
                      label: Text(localizations.messageActionMoveToInbox),
                    ),
                  )
                else if (!widget.message.isEmbedded)
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.delete,
                    child: IconText(
                      icon: Icon(iconService.messageActionDelete),
                      label: Text(localizations.messageActionDelete),
                    ),
                  ),
                if (!widget.message.isEmbedded) ...[
                  const PlatformPopupDivider(),
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.seen,
                    child: IconText(
                      icon: Icon(
                          iconService.getMessageIsSeen(widget.message.isSeen)),
                      label: Text(
                        widget.message.isSeen
                            ? localizations.messageStatusSeen
                            : localizations.messageStatusUnseen,
                      ),
                    ),
                  ),
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.flag,
                    child: IconText(
                      icon: Icon(iconService
                          .getMessageIsFlagged(widget.message.isFlagged)),
                      label: Text(
                        widget.message.isFlagged
                            ? localizations.messageStatusFlagged
                            : localizations.messageStatusUnflagged,
                      ),
                    ),
                  ),
                  if (widget.message.source.supportsMessageFolders) ...[
                    const PlatformPopupDivider(),
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.move,
                      child: IconText(
                        icon: Icon(iconService.messageActionMove),
                        label: Text(localizations.messageActionMove),
                      ),
                    ),
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.junk,
                      child: IconText(
                        icon: Icon(widget.message.source.isJunk
                            ? iconService.messageActionMoveFromJunkToInbox
                            : iconService.messageActionMoveToJunk),
                        label: Text(
                          widget.message.source.isJunk
                              ? localizations.messageActionMarkAsNotJunk
                              : localizations.messageActionMarkAsJunk,
                        ),
                      ),
                    ),
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.archive,
                      child: IconText(
                        icon: Icon(widget.message.source.isArchive
                            ? iconService.messageActionMoveToInbox
                            : iconService.messageActionArchive),
                        label: Text(
                          widget.message.source.isArchive
                              ? localizations.messageActionUnarchive
                              : localizations.messageActionArchive,
                        ),
                      ),
                    ),
                  ], // folders are supported
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.redirect,
                    child: IconText(
                      icon: Icon(iconService.messageActionRedirect),
                      label: Text(
                        localizations.messageActionRedirect,
                      ),
                    ),
                  ),
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.addNotification,
                    child: IconText(
                      icon: Icon(iconService.messageActionAddNotification),
                      label: Text(
                        localizations.messageActionAddNotification,
                      ),
                    ),
                  ),
                ], // message is not embedded in a different message
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onOverflowChoiceSelected(_OverflowMenuChoice result) {
    switch (result) {
      case _OverflowMenuChoice.reply:
        _reply();
        break;
      case _OverflowMenuChoice.replyAll:
        _replyAll();
        break;
      case _OverflowMenuChoice.forward:
        _forward();
        break;
      case _OverflowMenuChoice.forwardAsAttachment:
        _forwardAsAttachment();
        break;
      case _OverflowMenuChoice.forwardAttachments:
        _forwardAttachments();
        break;
      case _OverflowMenuChoice.delete:
        _delete();
        break;
      case _OverflowMenuChoice.inbox:
        _moveToInbox();
        break;
      case _OverflowMenuChoice.seen:
        _toggleSeen();
        break;
      case _OverflowMenuChoice.flag:
        _toggleFlagged();
        break;
      case _OverflowMenuChoice.move:
        _move();
        break;
      case _OverflowMenuChoice.junk:
        _moveJunk();
        break;
      case _OverflowMenuChoice.archive:
        _moveArchive();
        break;
      case _OverflowMenuChoice.redirect:
        _redirectMessage();
        break;
      case _OverflowMenuChoice.addNotification:
        _addNotification();
        break;
    }
  }

  // void _next() {
  //   _navigateToMessage(widget.message.next);
  // }

  // void _previous() {
  //   _navigateToMessage(widget.message.previous);
  // }

  // void _navigateToMessage(Message? message) {
  //   if (message != null) {
  //     locator<NavigationService>()
  //         .push(Routes.mailDetails, arguments: message, replace: true);
  //   }
  // }

  void _replyAll() {
    _reply(all: true);
  }

  void _reply({all = false}) {
    final account = widget.message.mailClient.account;

    final builder = MessageBuilder.prepareReplyToMessage(
      widget.message.mimeMessage,
      account.fromAddress,
      aliases: account.aliases,
      quoteOriginalText: false,
      handlePlusAliases: account.supportsPlusAliases,
      replyAll: all,
    );
    _navigateToCompose(widget.message, builder, ComposeAction.answer);
  }

  void _redirectMessage() async {
    final mailClient = widget.message.mailClient;
    final account = locator<MailService>().getAccountFor(mailClient.account)!;
    if (account.contactManager == null) {
      await locator<ContactService>().getForAccount(account);
    }

    final List<MailAddress> recipients = [];
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final textEditingController = TextEditingController();
    final redirect = await LocalizedDialogHelper.showWidgetDialog(
      context,
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
      title: localizations.redirectTitle,
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
        await LocalizedDialogHelper.showTextDialog(context,
            localizations.errorTitle, localizations.redirectEmailInputRequired);
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
        } on MailException catch (e, s) {
          if (kDebugMode) {
            print('message could not get redirected: $e $s');
          }
          await LocalizedDialogHelper.showTextDialog(
              context,
              localizations.errorTitle,
              localizations.resultRedirectedFailure(e.message ?? '<unknown>'));
        }
      }
    }
  }

  void _delete() async {
    locator<NavigationService>().pop();
    await widget.message.source.deleteMessages(
        [widget.message], locator<I18nService>().localizations.resultDeleted);
  }

  void _move() {
    final localizations = locator<I18nService>().localizations;
    LocalizedDialogHelper.showWidgetDialog(
      context,
      SingleChildScrollView(
        child: MailboxTree(
          account: widget.message.account,
          onSelected: _moveTo,
          current: widget.message.mailClient.selectedMailbox,
        ),
      ),
      title: localizations.moveTitle,
      defaultActions: DialogActions.cancel,
    );
  }

  void _moveTo(Mailbox mailbox) async {
    locator<NavigationService>().pop(); // alert
    locator<NavigationService>().pop(); // detail view
    final localizations = locator<I18nService>().localizations;
    final message = widget.message;
    final source = message.source;
    await source.moveMessage(
        message, mailbox, localizations.moveSuccess(mailbox.name));
  }

  void _moveJunk() async {
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

  void _moveToInbox() async {
    final source = widget.message.source;
    source.moveMessageToFlag(widget.message, MailboxFlag.inbox,
        locator<I18nService>().localizations.resultMovedToInbox);
    locator<NavigationService>().pop();
  }

  void _moveArchive() async {
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

  void _forward() {
    final from = widget.message.mailClient.account.fromAddress;
    final builder = MessageBuilder.prepareForwardMessage(
      widget.message.mimeMessage,
      from: from,
      quoteMessage: false,
      forwardAttachments: false,
    );
    final composeFuture = _addAttachments(widget.message, builder);
    _navigateToCompose(
        widget.message, builder, ComposeAction.forward, composeFuture);
  }

  void _forwardAsAttachment() async {
    final message = widget.message;
    final mailClient = message.mailClient;
    final from = mailClient.account.fromAddress;
    var mime = message.mimeMessage;
    final builder = MessageBuilder();
    builder.from = [from];

    builder.subject =
        MessageBuilder.createForwardSubject(mime.decodeSubject()!);
    Future? composeFuture;
    if (mime.mimeData == null) {
      composeFuture = mailClient.fetchMessageContents(mime).then((value) {
        message.updateMime(value);
        builder.addMessagePart(value);
      });
    } else {
      builder.addMessagePart(mime);
    }
    _navigateToCompose(
        widget.message, builder, ComposeAction.forward, composeFuture);
  }

  void _forwardAttachments() async {
    final message = widget.message;
    final mailClient = message.mailClient;
    final from = mailClient.account.fromAddress;
    var mime = message.mimeMessage;
    final builder = MessageBuilder();
    builder.from = [from];
    builder.subject =
        MessageBuilder.createForwardSubject(mime.decodeSubject()!);
    final composeFuture = _addAttachments(message, builder);
    _navigateToCompose(message, builder, ComposeAction.forward, composeFuture);
  }

  Future? _addAttachments(Message message, MessageBuilder builder) {
    final attachments = message.attachments;
    final mailClient = message.mailClient;
    var mime = message.mimeMessage;
    Future? composeFuture;
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

  void _toggleFlagged() async {
    final msg = widget.message;
    final flagged = !msg.isFlagged;
    await msg.source.markAsFlagged(msg, flagged);
  }

  void _toggleSeen() async {
    final msg = widget.message;
    final seen = !msg.isSeen;
    await msg.source.markAsSeen(msg, seen);
  }

  void _navigateToCompose(
      Message? message, MessageBuilder builder, ComposeAction action,
      [Future? composeFuture]) {
    final formatPreference =
        locator<SettingsService>().settings.replyFormatPreference;
    ComposeMode mode;
    switch (formatPreference) {
      case ReplyFormatPreference.alwaysHtml:
        mode = ComposeMode.html;
        break;
      case ReplyFormatPreference.sameFormat:
        if (message == null) {
          mode = ComposeMode.html;
        } else if (message.mimeMessage.hasPart(MediaSubtype.textHtml)) {
          mode = ComposeMode.html;
        } else if (message.mimeMessage.hasPart(MediaSubtype.textPlain)) {
          mode = ComposeMode.plainText;
        } else {
          mode = ComposeMode.html;
        }
        break;
      case ReplyFormatPreference.alwaysPlainText:
        mode = ComposeMode.plainText;
        break;
    }
    final data = ComposeData(
      [message],
      builder,
      action,
      future: composeFuture,
      composeMode: mode,
    );
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: data, replace: true);
  }

  void _addNotification() {
    locator<NotificationService>()
        .sendLocalNotificationForMailMessage(widget.message);
  }
}
