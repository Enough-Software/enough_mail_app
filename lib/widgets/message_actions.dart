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
          // IconButton(
          //     icon: Icon(Icons.arrow_left),
          //     onPressed: widget.message.hasPrevious ? previous : null),
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
          if (widget.message.source.supportsMessageFolders) ...{
            IconButton(
              icon: Icon(
                  widget.message.source.isJunk ? Entypo.check : Entypo.bug),
              onPressed: moveJunk,
            ),
          },
          Spacer(),
          IconButton(icon: Icon(Icons.reply), onPressed: reply),
          IconButton(icon: Icon(Icons.reply_all), onPressed: replyAll),
          IconButton(icon: Icon(Icons.forward), onPressed: forward),
          IconButton(icon: Icon(Icons.delete), onPressed: delete),
          // IconButton(
          //     icon: Icon(Icons.arrow_right),
          //     onPressed: widget.message.hasNext ? next : null),
        ],
      ),
    );
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
