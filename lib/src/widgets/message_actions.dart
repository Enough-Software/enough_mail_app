import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../contact/provider.dart';
import '../localization/extension.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../notification/service.dart';
import '../routes/routes.dart';
import '../scaffold_messenger/service.dart';
import '../settings/model.dart';
import '../settings/provider.dart';
import '../settings/theme/icon_service.dart';
import '../util/localized_dialog_helper.dart';
import '../util/validator.dart';
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

/// Displays actions for a single message.
class MessageActions extends HookConsumerWidget {
  /// Creates a [MessageActions] widget.
  const MessageActions({super.key, required this.message});

  /// The message to display actions for.
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final attachments = message.attachments;
    final iconService = IconService.instance;

    void onOverflowChoiceSelected(_OverflowMenuChoice result) {
      switch (result) {
        case _OverflowMenuChoice.reply:
          _reply(context, ref);
          break;
        case _OverflowMenuChoice.replyAll:
          _replyAll(context, ref);
          break;
        case _OverflowMenuChoice.forward:
          _forward(context, ref);
          break;
        case _OverflowMenuChoice.forwardAsAttachment:
          _forwardAsAttachment(context, ref);
          break;
        case _OverflowMenuChoice.forwardAttachments:
          _forwardAttachments(context, ref);
          break;
        case _OverflowMenuChoice.delete:
          _delete(context, ref);
          break;
        case _OverflowMenuChoice.inbox:
          _moveToInbox(context, ref);
          break;
        case _OverflowMenuChoice.seen:
          _toggleSeen();
          break;
        case _OverflowMenuChoice.flag:
          _toggleFlagged();
          break;
        case _OverflowMenuChoice.move:
          _move(context, ref);
          break;
        case _OverflowMenuChoice.junk:
          _moveJunk(context, ref);
          break;
        case _OverflowMenuChoice.archive:
          _moveArchive(context, ref);
          break;
        case _OverflowMenuChoice.redirect:
          _redirectMessage(context, ref);
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
                onPressed: () => _reply(context, ref),
              ),
              DensePlatformIconButton(
                icon: Icon(iconService.messageActionReplyAll),
                onPressed: () => _replyAll(context, ref),
              ),
              DensePlatformIconButton(
                icon: Icon(iconService.messageActionForward),
                onPressed: () => _forward(context, ref),
              ),
              if (message.source.isTrash)
                DensePlatformIconButton(
                  icon: Icon(iconService.messageActionMoveToInbox),
                  onPressed: () => _moveToInbox(context, ref),
                )
              else if (!message.isEmbedded)
                DensePlatformIconButton(
                  icon: Icon(iconService.messageActionDelete),
                  onPressed: () => _delete(context, ref),
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
                            attachments.length,
                          ),
                        ),
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
                          iconService.getMessageIsFlagged(message.isFlagged),
                        ),
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

  void _replyAll(BuildContext context, WidgetRef ref) {
    _reply(context, ref, all: true);
  }

  void _reply(BuildContext context, WidgetRef ref, {all = false}) {
    final account = message.account;
    final mime = message.mimeMessage;
    final recipientAddresses = mime.recipientAddresses;
    bool matchesRecipients(RealAccount account) {
      final aliases = [
        account.email,
        ...account.aliases.map((alias) => alias.email),
      ];
      for (final email in aliases) {
        if (recipientAddresses.contains(email)) {
          return true;
        }
      }

      return false;
    }

    final realAccount = account is RealAccount
        ? account
        : account is UnifiedAccount
            ? account.accounts.firstWhereOrNull(matchesRecipients)
            : null;

    final builder = MessageBuilder.prepareReplyToMessage(
      mime,
      realAccount?.fromAddress ?? account.fromAddress,
      aliases: realAccount?.aliases,
      handlePlusAliases: realAccount?.supportsPlusAliases ?? false,
      replyAll: all,
    );
    _navigateToCompose(context, ref, message, builder, ComposeAction.answer);
  }

  Future<void> _redirectMessage(BuildContext context, WidgetRef ref) async {
    final account = message.account;
    if (account is RealAccount) {
      account.contactManager ??=
          await ref.read(contactsLoaderProvider(account: account).future);
    }

    if (!context.mounted) {
      return;
    }
    final List<MailAddress> recipients = [];
    final localizations = ref.text;
    final size = MediaQuery.sizeOf(context);
    final textEditingController = TextEditingController();
    final redirect = await LocalizedDialogHelper.showWidgetDialog(
      ref,
      SingleChildScrollView(
        child: SizedBox(
          width: size.width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.redirectInfo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              RecipientInputField(
                addresses: recipients,
                contactManager:
                    account is RealAccount ? account.contactManager : null,
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
          child: Text(localizations.actionCancel),
          onPressed: () => context.pop(false),
        ),
        TextButton(
          child: Text(localizations.messageActionRedirect),
          onPressed: () {
            if (Validator.validateEmail(textEditingController.text)) {
              recipients.add(MailAddress(null, textEditingController.text));
            }
            context.pop(true);
          },
        ),
      ],
    );
    if (!context.mounted) {
      return;
    }
    if (redirect == true) {
      if (recipients.isEmpty) {
        await LocalizedDialogHelper.showTextDialog(
          ref,
          localizations.errorTitle,
          localizations.redirectEmailInputRequired,
        );
      } else {
        final mime = message.mimeMessage;
        if (mime.mimeData == null) {
          // download complete message first
          await message.source.fetchMessageContents(message);
        }
        try {
          await message.source.getMimeSource(message)?.sendMessage(
                mime,
                recipients: recipients,
                appendToSent: false,
              );
          ScaffoldMessengerService.instance.showTextSnackBar(
            localizations,
            localizations.resultRedirectedSuccess,
          );
        } on MailException catch (e, s) {
          if (kDebugMode) {
            print('message could not get redirected: $e $s');
          }
          if (!context.mounted) {
            return;
          }
          await LocalizedDialogHelper.showTextDialog(
            ref,
            localizations.errorTitle,
            localizations.resultRedirectedFailure(e.message ?? '<unknown>'),
          );
        }
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final localizations = ref.text;
    context.pop();
    await message.source.deleteMessages(
      localizations,
      [message],
      localizations.resultDeleted,
    );
  }

  void _move(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    LocalizedDialogHelper.showWidgetDialog(
      ref,
      SingleChildScrollView(
        child: MailboxTree(
          account: message.account,
          onSelected: (mailbox) => _moveTo(context, ref, mailbox),
          // TODO(RV): retrieve the current selected mailbox in a different way
          // current:  message.mailClient.selectedMailbox,
        ),
      ),
      title: localizations.moveTitle,
      defaultActions: DialogActions.cancel,
    );
  }

  Future<void> _moveTo(
      BuildContext context, WidgetRef ref, Mailbox mailbox) async {
    context
      ..pop() // alert
      ..pop(); // detail view
    final localizations = ref.text;
    final source = message.source;
    await source.moveMessage(
      localizations,
      message,
      mailbox,
      localizations.moveSuccess(mailbox.name),
    );
  }

  Future<void> _moveJunk(BuildContext context, WidgetRef ref) async {
    final source = message.source;
    if (source.isJunk) {
      await source.markAsNotJunk(ref.text, message);
    } else {
      NotificationService.instance.cancelNotificationForMessage(message);
      await source.markAsJunk(ref.text, message);
    }
    if (context.mounted) {
      context.pop();
    }
  }

  Future<void> _moveToInbox(BuildContext context, WidgetRef ref) async {
    final source = message.source;
    final localizations = ref.text;
    await source.moveMessageToFlag(
      localizations,
      message,
      MailboxFlag.inbox,
      localizations.resultMovedToInbox,
    );
    if (context.mounted) {
      context.pop();
    }
  }

  Future<void> _moveArchive(BuildContext context, WidgetRef ref) async {
    final source = message.source;
    if (source.isArchive) {
      await source.moveToInbox(ref.text, message);
    } else {
      NotificationService.instance.cancelNotificationForMessage(message);
      await source.archive(ref.text, message);
    }
    if (context.mounted) {
      context.pop();
    }
  }

  void _forward(BuildContext context, WidgetRef ref) {
    final from = message.account.fromAddress;
    final builder = MessageBuilder.prepareForwardMessage(
      message.mimeMessage,
      from: from,
      quoteMessage: false,
      forwardAttachments: false,
    );
    final composeFuture = _addAttachments(message, builder);
    _navigateToCompose(
      context,
      ref,
      message,
      builder,
      ComposeAction.forward,
      composeFuture,
    );
  }

  Future<void> _forwardAsAttachment(BuildContext context, WidgetRef ref) async {
    final message = this.message;
    final from = message.account.fromAddress;
    final mime = message.mimeMessage;
    final builder = MessageBuilder()
      ..from = [from]
      ..subject = MessageBuilder.createForwardSubject(
        mime.decodeSubject() ?? '',
      );
    Future? composeFuture;
    if (mime.mimeData == null) {
      composeFuture = message.source.fetchMessageContents(message).then(
            builder.addMessagePart,
          );
    } else {
      builder.addMessagePart(mime);
    }
    _navigateToCompose(
      context,
      ref,
      message,
      builder,
      ComposeAction.forward,
      composeFuture,
    );
  }

  Future<void> _forwardAttachments(BuildContext context, WidgetRef ref) async {
    final message = this.message;
    final from = message.account.fromAddress;
    final mime = message.mimeMessage;
    final builder = MessageBuilder()
      ..from = [from]
      ..subject = MessageBuilder.createForwardSubject(
        mime.decodeSubject() ?? '',
      );
    final composeFuture = _addAttachments(message, builder);
    _navigateToCompose(
      context,
      ref,
      message,
      builder,
      ComposeAction.forward,
      composeFuture,
    );
  }

  Future? _addAttachments(Message message, MessageBuilder builder) {
    final attachments = message.attachments;
    final mime = message.mimeMessage;
    Future? composeFuture;
    if (mime.mimeData == null && attachments.length > 1) {
      composeFuture = message.source.fetchMessageContents(message).then(
        (value) {
          for (final attachment in attachments) {
            final part = value.getPart(attachment.fetchId);
            builder.addPart(mimePart: part);
          }
        },
      );
    } else {
      final futures = <Future>[];
      for (final attachment in message.attachments) {
        final part = mime.getPart(attachment.fetchId);
        if (part != null) {
          builder.addPart(mimePart: part);
        } else {
          futures.add(
            message.source
                .fetchMessagePart(message, fetchId: attachment.fetchId)
                .then(
              (value) {
                builder.addPart(mimePart: value);
              },
            ),
          );
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
    BuildContext context,
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
    context.pushReplacementNamed(Routes.mailCompose, extra: data);
  }

  void _addNotification() {
    NotificationService.instance.sendLocalNotificationForMailMessage(message);
  }
}
