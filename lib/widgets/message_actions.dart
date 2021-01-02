import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
  junk,
  seen,
  flag,
  archive
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
    return Material(
      elevation: 16,
      child: Row(
        children: [
          IconButton(
            icon: Icon(widget.message.isSeen
                ? Feather.circle // Icons.check_circle_outline
                : Entypo.mail_with_circle), //Icons.check_circle),
            onPressed: toggleSeen,
          ),
          IconButton(
            icon: Icon(
                widget.message.isFlagged ? Icons.flag : Icons.outlined_flag),
            onPressed: toggleFlagged,
          ),
          Spacer(),
          IconButton(icon: Icon(Icons.reply), onPressed: reply),
          IconButton(icon: Icon(Icons.reply_all), onPressed: replyAll),
          IconButton(icon: Icon(Icons.forward), onPressed: forward),
          IconButton(icon: Icon(Icons.delete), onPressed: delete),
          PopupMenuButton<_OverflowMenuChoice>(
            onSelected: onOverflowChoiceSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _OverflowMenuChoice.reply,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.reply),
                    Text(' reply'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _OverflowMenuChoice.replyAll,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.reply_all),
                    Text(' reply all'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _OverflowMenuChoice.forward,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.forward),
                    Text(' forward'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _OverflowMenuChoice.delete,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.delete),
                    Text(' delete'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _OverflowMenuChoice.seen,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(widget.message.isSeen
                        ? Feather.circle
                        : Entypo.mail_with_circle),
                    Text(widget.message.isSeen ? ' is read' : ' is not read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _OverflowMenuChoice.flag,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(widget.message.isFlagged
                        ? Icons.flag
                        : Icons.outlined_flag),
                    Text(widget.message.isFlagged
                        ? ' is flagged'
                        : ' is not flagged'),
                  ],
                ),
              ),
              if (widget.message.source.supportsMessageFolders) ...{
                PopupMenuDivider(),
                PopupMenuItem(
                  value: _OverflowMenuChoice.junk,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(widget.message.source.isJunk
                          ? Entypo.check
                          : Entypo.bug),
                      Text(widget.message.source.isJunk
                          ? ' mark as not junk'
                          : ' mark as junk'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _OverflowMenuChoice.archive,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(widget.message.source.isArchive
                          ? Entypo.inbox
                          : Entypo.archive),
                      Text(widget.message.source.isArchive
                          ? ' move to inbox'
                          : ' archive'),
                    ],
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
    //TODO in case of a unified account the current account is not bound to a single identity
    final account = locator<MailService>().currentAccount;

    var builder = MessageBuilder.prepareReplyToMessage(
        widget.message.mimeMessage, account.fromAddress,
        aliases: account.aliases,
        quoteOriginalText: true,
        handlePlusAliases: account.supportsPlusAliases ?? false,
        replyAll: all);
    navigateToCompose(widget.message, builder, ComposeAction.answer);
  }

  void redirectMessage() {}

  void delete() async {
    await widget.message.source.deleteMessage(context, widget.message);
    locator<NavigationService>().pop();
  }

  void moveJunk() async {
    final source = widget.message.source;
    if (source.isJunk) {
      await widget.message.source.markAsNotJunk(context, widget.message);
    } else {
      await widget.message.source.markAsJunk(context, widget.message);
    }
    locator<NavigationService>().pop();
  }

  void moveArchive() async {
    final source = widget.message.source;
    if (source.isArchive) {
      await widget.message.source.moveToInbox(context, widget.message);
    } else {
      await widget.message.source.archive(context, widget.message);
    }
    locator<NavigationService>().pop();
  }

  void forward() {
    var from = locator<MailService>().currentAccount.fromAddress;
    var builder = MessageBuilder.prepareForwardMessage(
      widget.message.mimeMessage,
      from: from,
    );
    navigateToCompose(widget.message, builder, ComposeAction.forward);
  }

  void toggleFlagged() async {
    final flagged = !widget.message.isFlagged;
    widget.message.isFlagged = flagged;
    final msg = widget.message;
    await msg.mailClient.flagMessage(msg.mimeMessage, isFlagged: flagged);
  }

  void toggleSeen() async {
    final seen = !widget.message.isSeen;
    widget.message.isSeen = seen;
    final msg = widget.message;
    await msg.mailClient.flagMessage(msg.mimeMessage, isSeen: seen);
  }

  void navigateToCompose(
      Message message, MessageBuilder builder, ComposeAction action) {
    final data = ComposeData(message, builder, action);
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: data, replace: true);
  }
}
