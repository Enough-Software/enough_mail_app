import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/sender.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import 'base.dart';

class ComposeScreen2 extends StatefulWidget {
  final ComposeData data;
  ComposeScreen2({@required this.data, key}) : super(key: key);

  @override
  _ComposeScreenState2 createState() => _ComposeScreenState2();
}

enum _OverflowMenuChoice { showSourceCode, saveAsDraft }

class _ComposeScreenState2 extends State<ComposeScreen2> {
  TextEditingController _toController = TextEditingController();
  TextEditingController _ccController = TextEditingController();
  TextEditingController _bccController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  ScrollController _scrollController;

  bool _showSource = false;
  String _source;
  Sender from;
  List<Sender> senders;

  @override
  void initState() {
    _scrollController = ScrollController();
    final mb = widget.data.messageBuilder;
    initRecipient(mb.to, _toController);
    initRecipient(mb.cc, _ccController);
    initRecipient(mb.bcc, _bccController);
    _subjectController.text = mb.subject;
    _contentController.text = mb.text; //TODO check
    senders = locator<MailService>().getSenders();
    final currentAccount = locator<MailService>().currentAccount;
    if (mb.from == null) {
      mb.from = [currentAccount.fromAddress];
    }
    final senderEmail = mb.from.first.email.toLowerCase();
    from = senders.firstWhere(
        (s) => s.address?.email?.toLowerCase() == senderEmail,
        orElse: () => null);
    if (from == null) {
      from = Sender(mb.from.first, currentAccount);
      senders.insert(0, from);
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  MimeMessage buildMimeMessage() {
    final mb = widget.data.messageBuilder;
    mb.to = parse(_toController.text);
    mb.cc = parse(_ccController.text);
    mb.bcc = parse(_bccController.text);
    mb.subject = _subjectController.text;
    mb.text = _contentController.text;
    var mimeMessage = mb.buildMimeMessage();
    return mimeMessage;
  }

  Future<void> send() async {
    locator<NavigationService>().pop();
    var mailClient = await locator<MailService>().getClientFor(from.account);
    var mimeMessage = buildMimeMessage();
    //TODO enable global busy indicator
    //TODO check first if message can be sent or catch errors
    var response = await mailClient.sendMessage(mimeMessage,
        from: from.account.fromAddress);
    print('message sent successfully: ${response.isOkStatus}');
    //TODO disable global busy indicator
    if (response.isOkStatus) {
      var storeFlags = true;
      final message = widget.data.originalMessage;
      switch (widget.data.action) {
        case ComposeAction.answer:
          message.isAnswered = true;
          break;
        case ComposeAction.forward:
          message.isForwarded = true;
          break;
        case ComposeAction.newMessage:
          storeFlags = false;
          // no action to do
          break;
      }
      if (storeFlags) {
        await mailClient.store(MessageSequence.fromMessage(message.mimeMessage),
            message.mimeMessage.flags,
            action: StoreAction.replace);
      }
    }
  }

  List<MailAddress> parse(String text) {
    if (text?.isEmpty ?? true) {
      return null;
    }
    return text
        .split(';')
        .map<MailAddress>((t) => MailAddress(null, t.trim()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: widget.data.action == ComposeAction.answer
          ? 'Reply'
          : widget.data.action == ComposeAction.forward
              ? 'Forward'
              : 'New message',
      content: buildContent(),
      appBarActions: [
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            send();
          },
        ),
        PopupMenuButton<_OverflowMenuChoice>(
          onSelected: (_OverflowMenuChoice result) {
            switch (result) {
              case _OverflowMenuChoice.showSourceCode:
                showSourceCode();
                break;
              case _OverflowMenuChoice.saveAsDraft:
                saveAsDraft();
                break;
            }
          },
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<_OverflowMenuChoice>>[
            const PopupMenuItem<_OverflowMenuChoice>(
              value: _OverflowMenuChoice.showSourceCode,
              child: Text('View source'),
            ),
            const PopupMenuItem<_OverflowMenuChoice>(
              value: _OverflowMenuChoice.saveAsDraft,
              child: Text('Save as draft'),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildContent() {
    if (_showSource) {
      return SingleChildScrollView(
        child: Text(_source),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From', style: Theme.of(context).textTheme?.caption),
                DropdownButton<Sender>(
                  isExpanded: true,
                  items: senders
                      .map(
                        (s) => DropdownMenuItem<Sender>(
                          value: s,
                          child: Text(
                            s.isPlaceHolderForPlusAlias
                                ? 'Create new + alias...'
                                : s.toString(),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      )
                      .toList(),
                  // selectedItemBuilder: (context) => senders
                  //     .map(
                  //       (s) => Text(
                  //         s.isPlaceHolderForPlusAlias
                  //             ? 'Create new + alias...'
                  //             : s.toString(),
                  //         overflow: TextOverflow.fade,
                  //       ),
                  //     )
                  //     .toList(),
                  onChanged: (s) async {
                    if (s.isPlaceHolderForPlusAlias) {
                      final index = senders.indexOf(s);
                      s = locator<MailService>()
                          .generateRandomPlusAliasSender(s);
                      setState(() {
                        senders.insert(index, s);
                      });
                      // final newAliasAddress = await showDialog<MailAddress>(
                      //   context: context,
                      //   builder: (context) => AliasEditDialog(
                      //       isNewAlias: true, alias: alias.address, account: Account(s.account),),
                      // );
                      // if (newAliasAddress != null) {

                      // }
                    }
                    widget.data.messageBuilder.from = [s.address];
                    setState(() {
                      from = s;
                    });
                  },
                  value: from,
                  hint: Text('Sender'),
                ),
                TextField(
                  controller: _toController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'To', hintText: 'Recipient email'),
                ),
                TextField(
                  controller: _ccController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'CC', hintText: 'Recipient email'),
                ),
                TextField(
                  controller: _bccController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'BCC', hintText: 'Recipient email'),
                ),
                TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                      labelText: 'Subject', hintText: 'Message subject'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(8.0),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 400,
              //         HtmlEditor(
              //     hint: "Your text here...",
              //     //value: "text content initial, if any",
              //     key: keyEditor,
              //     height: 400,
              // ),
              // child: ZefyrScaffold(
              //   child: ZefyrEditor(
              //     padding: EdgeInsets.all(16),
              //     controller: _richContentController,
              //     focusNode: _richContentFocusNode,
              //   ),
              // ),
              child: TextField(
                controller: _contentController,
                //maxLines: null,
                maxLines: 2000,
                //expands: true,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(hintText: 'Your message goes here'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void initRecipient(
      List<MailAddress> addresses, TextEditingController textController) {
    textController.text = addresses?.isEmpty ?? true
        ? ''
        : addresses.map((a) => a.email).join('; ');
  }

  void showSourceCode() {
    if (!_showSource) {
      var message = buildMimeMessage();
      _source = message.renderMessage();
    }
    setState(() {
      _showSource = !_showSource;
    });
  }

  void saveAsDraft() {}
}

// class AppProfile {
//   final String name;
//   final String email;
//   final String imageUrl;

//   const AppProfile(this.name, this.email, this.imageUrl);

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is AppProfile &&
//           runtimeType == other.runtimeType &&
//           name == other.name;

//   @override
//   int get hashCode => name.hashCode;

//   @override
//   String toString() {
//     return name;
//   }
// }
