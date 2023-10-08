import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../locator.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../routes.dart';
import '../services/contact_service.dart';
import '../services/i18n_service.dart';
import '../services/icon_service.dart';
import '../services/mail_service.dart';
import '../services/navigation_service.dart';
import '../services/notification_service.dart';
import '../services/scaffold_messenger_service.dart';
import '../settings/model.dart';
import '../settings/provider.dart';
import '../util/localized_dialog_helper.dart';
import '../util/validator.dart';
import 'button_text.dart';
import 'icon_text.dart';
import 'mailbox_tree.dart';
import 'recipient_input_field.dart';

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

class MessageActions extends HookConsumerWidget {
  const MessageActions({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.text;
    final attachments = message.attachments;
    final iconService = locator<IconService>();

    void onOverflowChoiceSelected(_OverflowMenuChoice result) {
      switch (result) {
        case _OverflowMenuChoice.reply:
          _reply(ref);
          break;
        case _OverflowMenuChoice.replyAll:
          _replyAll(ref);
          break;
        case _OverflowMenuChoice.forward:
          _forward(ref);
          break;
        case _OverflowMenuChoice.forwardAsAttachment:
          _forwardAsAttachment(ref);
          break;
        case _OverflowMenuChoice.forwardAttachments:
          _forwardAttachments(ref);
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
          _move(context);
          break;
        case _OverflowMenuChoice.junk:
          _moveJunk();
          break;
        case _OverflowMenuChoice.archive:
          _moveArchive();
          break;
        case _OverflowMenuChoice.redirect:
          _redirectMessage(context);
          break;
        case _OverflowMenuChoice.addNotification:
          _addNotification();
          break;
      }
    }

    return PlatformBottomBar(
      cupertinoBackgroundOpacity: 0.8,
      child: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: message,
          builder: (context, child) => Row(
            children: [
              if (!message.isEmbedded) ...[
                DensePlatformIconButton(
                  icon: Icon(iconService.getMessageIsSeen(message.isSeen)),
                  onPressed: _toggleSeen,
                ),
                DensePlatformIconButton(
                  icon:
                      Icon(iconService.getMessageIsFlagged(message.isFlagged)),
                  onPressed: _toggleFlagged,
                ),
              ],
              const Spacer(),
              DensePlatformIconButton(
                icon: Icon(iconService.messageActionReply),
                onPressed: () => _reply(ref),
              ),
              DensePlatformIconButton(
                icon: Icon(iconService.messageActionReplyAll),
                onPressed: () => _replyAll(ref),
              ),
              DensePlatformIconButton(
                icon: Icon(iconService.messageActionForward),
                onPressed: () => _forward(ref),
              ),
              if (message.source.isTrash)
                DensePlatformIconButton(
                  icon: Icon(iconService.messageActionMoveToInbox),
                  onPressed: _moveToInbox,
                )
              else if (!message.isEmbedded)
                DensePlatformIconButton(
                  icon: Icon(iconService.messageActionDelete),
                  onPressed: _delete,
                ),
              PlatformPopupMenuButton<_OverflowMenuChoice>(
                onSelected: onOverflowChoiceSelected,
                itemBuilder: (context) => [
                  PlatformPopupMenuItem(
                    value: _OverflowMenuChoice.reply,
                    child: IconText(
                      icon: Icon(iconService.messageActionReply),
                      label: Text(localizations.messageActionReply),
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
                      label:
                          Text(localizations.messageActionForwardAsAttachment),
                    ),
                  ),
                  if (attachments.isNotEmpty)
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.forwardAttachments,
                      child: IconText(
                        icon: Icon(iconService.messageActionForwardAttachments),
                        label: Text(
                            localizations.messageActionForwardAttachments(
                                attachments.length)),
                      ),
                    ),
                  if (message.source.isTrash)
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.inbox,
                      child: IconText(
                        icon: Icon(iconService.messageActionMoveToInbox),
                        label: Text(localizations.messageActionMoveToInbox),
                      ),
                    )
                  else if (!message.isEmbedded)
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.delete,
                      child: IconText(
                        icon: Icon(iconService.messageActionDelete),
                        label: Text(localizations.messageActionDelete),
                      ),
                    ),
                  if (!message.isEmbedded) ...[
                    const PlatformPopupDivider(),
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.seen,
                      child: IconText(
                        icon:
                            Icon(iconService.getMessageIsSeen(message.isSeen)),
                        label: Text(
                          message.isSeen
                              ? localizations.messageStatusSeen
                              : localizations.messageStatusUnseen,
                        ),
                      ),
                    ),
                    PlatformPopupMenuItem(
                      value: _OverflowMenuChoice.flag,
                      child: IconText(
                        icon: Icon(
                            iconService.getMessageIsFlagged(message.isFlagged)),
                        label: Text(
                          message.isFlagged
                              ? localizations.messageStatusFlagged
                              : localizations.messageStatusUnflagged,
                        ),
                      ),
                    ),
                    if (message.source.supportsMessageFolders) ...[
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
                          icon: Icon(message.source.isJunk
                              ? iconService.messageActionMoveFromJunkToInbox
                              : iconService.messageActionMoveToJunk),
                          label: Text(
                            message.source.isJunk
                                ? localizations.messageActionMarkAsNotJunk
                                : localizations.messageActionMarkAsJunk,
                          ),
                        ),
                      ),
                      PlatformPopupMenuItem(
                        value: _OverflowMenuChoice.archive,
                        child: IconText(
                          icon: Icon(message.source.isArchive
                              ? iconService.messageActionMoveToInbox
                              : iconService.messageActionArchive),
                          label: Text(
                            message.source.isArchive
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
      ),
    );
  }

  // void _next() {
  //   _navigateToMessage(message.next);
  // }

  // void _previous() {
  //   _navigateToMessage(message.previous);
  // }

  // void _navigateToMessage(Message? message) {
  //   if (message != null) {
  //     locator<NavigationService>()
  //         .push(Routes.mailDetails, arguments: message, replace: true);
  //   }
  // }

  void _replyAll(WidgetRef ref) {
    _reply(ref, all: true);
  }

  void _reply(WidgetRef ref, {all = false}) {
    final account = message.mailClient.account;

    final builder = MessageBuilder.prepareReplyToMessage(
      message.mimeMessage,
      account.fromAddress,
      aliases: account.aliases,
      handlePlusAliases: account.supportsPlusAliases,
      replyAll: all,
    );
    _navigateToCompose(ref, message, builder, ComposeAction.answer);
  }

  Future<void> _redirectMessage(BuildContext context) async {
    final mailClient = message.mailClient;
    final account = locator<MailService>().getAccountFor(mailClient.account)!;
    if (account.contactManager == null) {
      await locator<ContactService>().getForAccount(account);
    }

    if (!context.mounted) {
      return;
    }
    final List<MailAddress> recipients = [];
    final localizations = context.text;
    final size = MediaQuery.sizeOf(context);
    final textEditingController = TextEditingController();
    final redirect = await LocalizedDialogHelper.showWidgetDialog(
      context,
      SingleChildScrollView(
        child: SizedBox(
          width: size.width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.redirectInfo,
                  style: Theme.of(context).textTheme.bodySmall),
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
    if (!context.mounted) {
      return;
    }
    if (redirect == true) {
      if (recipients.isEmpty) {
        await LocalizedDialogHelper.showTextDialog(context,
            localizations.errorTitle, localizations.redirectEmailInputRequired);
      } else {
        final mime = message.mimeMessage;
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
          if (!context.mounted) {
            return;
          }
          await LocalizedDialogHelper.showTextDialog(
            context,
            localizations.errorTitle,
            localizations.resultRedirectedFailure(e.message ?? '<unknown>'),
          );
        }
      }
    }
  }

  Future<void> _delete() async {
    locator<NavigationService>().pop();
    await message.source.deleteMessages(
      [message],
      locator<I18nService>().localizations.resultDeleted,
    );
  }

  void _move(BuildContext context) {
    final localizations = locator<I18nService>().localizations;
    LocalizedDialogHelper.showWidgetDialog(
      context,
      SingleChildScrollView(
        child: MailboxTree(
          account: message.account,
          onSelected: _moveTo,
          current: message.mailClient.selectedMailbox,
        ),
      ),
      title: localizations.moveTitle,
      defaultActions: DialogActions.cancel,
    );
  }

  Future<void> _moveTo(Mailbox mailbox) async {
    locator<NavigationService>().pop(); // alert
    locator<NavigationService>().pop(); // detail view
    final localizations = locator<I18nService>().localizations;
    final source = message.source;
    await source.moveMessage(
      message,
      mailbox,
      localizations.moveSuccess(mailbox.name),
    );
  }

  Future<void> _moveJunk() async {
    final source = message.source;
    if (source.isJunk) {
      await source.markAsNotJunk(message);
    } else {
      locator<NotificationService>().cancelNotificationForMailMessage(message);
      await source.markAsJunk(message);
    }
    locator<NavigationService>().pop();
  }

  Future<void> _moveToInbox() async {
    final source = message.source;
    await source.moveMessageToFlag(message, MailboxFlag.inbox,
        locator<I18nService>().localizations.resultMovedToInbox);
    locator<NavigationService>().pop();
  }

  Future<void> _moveArchive() async {
    final source = message.source;
    if (source.isArchive) {
      await source.moveToInbox(message);
    } else {
      locator<NotificationService>().cancelNotificationForMailMessage(message);
      await source.archive(message);
    }
    locator<NavigationService>().pop();
  }

  void _forward(WidgetRef ref) {
    final from = message.mailClient.account.fromAddress;
    final builder = MessageBuilder.prepareForwardMessage(
      message.mimeMessage,
      from: from,
      quoteMessage: false,
      forwardAttachments: false,
    );
    final composeFuture = _addAttachments(message, builder);
    _navigateToCompose(
      ref,
      message,
      builder,
      ComposeAction.forward,
      composeFuture,
    );
  }

  Future<void> _forwardAsAttachment(WidgetRef ref) async {
    final message = this.message;
    final mailClient = message.mailClient;
    final from = mailClient.account.fromAddress;
    final mime = message.mimeMessage;
    final builder = MessageBuilder()
      ..from = [from]
      ..subject = MessageBuilder.createForwardSubject(mime.decodeSubject()!);
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
      ref,
      message,
      builder,
      ComposeAction.forward,
      composeFuture,
    );
  }

  Future<void> _forwardAttachments(WidgetRef ref) async {
    final message = this.message;
    final mailClient = message.mailClient;
    final from = mailClient.account.fromAddress;
    final mime = message.mimeMessage;
    final builder = MessageBuilder()
      ..from = [from]
      ..subject = MessageBuilder.createForwardSubject(mime.decodeSubject()!);
    final composeFuture = _addAttachments(message, builder);
    _navigateToCompose(
      ref,
      message,
      builder,
      ComposeAction.forward,
      composeFuture,
    );
  }

  Future? _addAttachments(Message message, MessageBuilder builder) {
    final attachments = message.attachments;
    final mailClient = message.mailClient;
    final mime = message.mimeMessage;
    Future? composeFuture;
    if (mime.mimeData == null && attachments.length > 1) {
      composeFuture = mailClient.fetchMessageContents(mime).then((value) {
        message.updateMime(value);
        for (final attachment in attachments) {
          final part = value.getPart(attachment.fetchId);
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

  Future<void> _toggleFlagged() async {
    final msg = message;
    final flagged = !msg.isFlagged;
    await msg.source.markAsFlagged(msg, flagged);
  }

  Future<void> _toggleSeen() async {
    final msg = message;
    final seen = !msg.isSeen;
    await msg.source.markAsSeen(msg, seen);
  }

  void _navigateToCompose(
    WidgetRef ref,
    Message? message,
    MessageBuilder builder,
    ComposeAction action, [
    Future? composeFuture,
  ]) {
    final formatPreference = ref.read(settingsProvider).replyFormatPreference;
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
    locator<NotificationService>().sendLocalNotificationForMailMessage(message);
  }
}
