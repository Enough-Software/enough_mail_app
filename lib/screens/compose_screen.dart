import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/sender.dart';
import 'package:enough_mail_app/services/dialog_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_mail_app/widgets/attachment_compose_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import '../routes.dart';

class ComposeScreen extends StatefulWidget {
  final ComposeData data;
  ComposeScreen({@required this.data, key}) : super(key: key);

  @override
  _ComposeScreenState createState() => _ComposeScreenState();
}

enum _OverflowMenuChoice { showSourceCode, saveAsDraft }
enum _Autofocus { to, subject, text }

class _ComposeScreenState extends State<ComposeScreen> {
  TextEditingController _toController = TextEditingController();
  TextEditingController _ccController = TextEditingController();
  TextEditingController _bccController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  // TextEditingController _contentController = TextEditingController();

  Sender from;
  List<Sender> senders;
  _Autofocus _focus;
  bool _isCcBccVisible = false;
  TransferEncoding _usedTextEncoding;
  Future<String> loadMailTextFuture;
  EditorApi _editorApi;
  Future _downloadAttachmentsFuture;
  String _originalMessageHtml;
  ComposeData _resumeComposeData;

  @override
  void initState() {
    final mb = widget.data.messageBuilder;
    initRecipient(mb.to, _toController);
    initRecipient(mb.cc, _ccController);
    initRecipient(mb.bcc, _bccController);
    _isCcBccVisible =
        _ccController.text.isNotEmpty || _bccController.text.isNotEmpty;
    _subjectController.text = mb.subject;
    _focus = ((_toController.text?.isEmpty ?? true) &&
            (_ccController.text?.isEmpty ?? true))
        ? _Autofocus.to
        : (_subjectController.text?.isEmpty ?? true)
            ? _Autofocus.subject
            : _Autofocus.text;
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
    if (widget.data.resumeHtmlText != null) {
      loadMailTextFuture = loadMailTextFromComposeData();
    } else {
      loadMailTextFuture = loadMailTextFromMessage();
      if (widget.data.action == ComposeAction.forward &&
          widget.data.originalMessage != null) {
        // start initializing any attachments:
        final attachments = mb.originalMessage
            .findContentInfo(disposition: ContentDisposition.attachment);
        if (attachments.isNotEmpty) {
          final attachmentsToBeLoaded = <ContentInfo>[];
          for (final attachment in attachments) {
            final part = mb.originalMessage.getPart(attachment.fetchId);
            if (part == null) {
              // add future part
              attachmentsToBeLoaded.add(attachment);
            }
          }
          if (attachmentsToBeLoaded.isNotEmpty) {
            _downloadAttachmentsFuture = downloadAttachments(mb.originalMessage,
                widget.data.originalMessage.mailClient, attachments);
          }
        }
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    // _contentController.dispose();
    super.dispose();
  }

  Future<void> downloadAttachments(MimeMessage mimeMessage,
      MailClient mailClient, List<ContentInfo> attachments) async {
    if (attachments.length == 1) {
      // just download the attachment:
      final part = await mailClient.fetchMessagePart(
          mimeMessage, attachments.first.fetchId);
      widget.data.messageBuilder.addPart(mimePart: part);
    } else {
      // download the full message:
      final msg = await mailClient.fetchMessageContents(mimeMessage);
      for (final attachment in attachments) {
        final part = msg.getPart(attachment.fetchId);
        if (part != null) {
          widget.data.messageBuilder.addPart(mimePart: part);
        }
      }
    }

    setState(() {
      _downloadAttachmentsFuture = null;
    });
  }

  Future<String> loadMailTextFromComposeData() {
    return Future.value(widget.data.resumeHtmlText);
  }

  Future<String> loadMailTextFromMessage() async {
    final mb = widget.data.messageBuilder;
    if (mb.originalMessage == null) {
      return '<p></p>';
    } else {
      final blockExternalImages = false;
      final emptyMessageText =
          locator<I18nService>().localizations.composeEmptyMessage;
      final maxImageWidth = 300;
      if (widget.data.action == ComposeAction.newMessage) {
        // continue with draft:
        final args = _HtmlGenerationArguments(null, mb.originalMessage,
            blockExternalImages, emptyMessageText, maxImageWidth);
        final html = await compute(_generateDraftHtmlImpl, args);
        _originalMessageHtml = html;
        return html;
      }
      final quoteTemplate = widget.data.action == ComposeAction.answer
          ? MailConventions.defaultReplyHeaderTemplate
          : widget.data.action == ComposeAction.forward
              ? MailConventions.defaultForwardHeaderTemplate
              : MailConventions.defaultReplyHeaderTemplate;
      final args = _HtmlGenerationArguments(quoteTemplate, mb.originalMessage,
          blockExternalImages, emptyMessageText, maxImageWidth);
      final html = await compute(_generateQuoteHtmlImpl, args);
      _originalMessageHtml = html;
      return html;
    }
  }

  static String _generateQuoteHtmlImpl(_HtmlGenerationArguments args) {
    final html = args.mimeMessage.quoteToHtml(
      quoteHeaderTemplate: args.quoteTemplate,
      blockExternalImages: args.blockExternalImages,
      emptyMessageText: args.emptyMessageText,
      maxImageWidth: args.maxImageWidth,
    );
    return html;
  }

  static String _generateDraftHtmlImpl(_HtmlGenerationArguments args) {
    final html = args.mimeMessage.transformToHtml(
        emptyMessageText: args.emptyMessageText,
        maxImageWidth: args.maxImageWidth,
        blockExternalImages: args.blockExternalImages);
    return html;
  }

  Future<void> populateMessageBuilder({bool storeHtmlForResume = false}) async {
    final mb = widget.data.messageBuilder;
    mb.to = parse(_toController.text);
    mb.cc = parse(_ccController.text);
    mb.bcc = parse(_bccController.text);
    mb.subject = _subjectController.text;

    final htmlText = await _editorApi.getText();
    if (storeHtmlForResume) {
      _resumeComposeData = widget.data.resume(htmlText);
    } else {
      // print('got html: $htmlText');
      var newHtmlText = htmlText;
      final htmlTagRegex =
          RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
      if (_originalMessageHtml != null) {
        // check for simple case first:
        var original = _originalMessageHtml;
        int blockquoteStart = original.indexOf('<blockquote>');
        if (blockquoteStart != -1) {
          original = original.substring(blockquoteStart);
        }
        final originalStartIndex = htmlText.indexOf(original);
        if (originalStartIndex != -1) {
          newHtmlText = htmlText.replaceFirst(original, '', originalStartIndex);
        } else {
          //TODO Here the text should be added at the correct positions and not just at the front of the plain text message...
          // create a diff between the original HTML and the new HTML:
          final buffer = StringBuffer();
          DiffMatchPatch dmp = new DiffMatchPatch();
          List<Diff> diffs = dmp.diff(newHtmlText, _originalMessageHtml);
          dmp.diffCleanupSemantic(diffs);
          for (final diff in diffs) {
            // print('diff: ${diff.operation}: ${diff.text}');
            if (diff.operation == -1) {
              // this is new text:
              buffer.write(diff.text);
            }
          }
          newHtmlText = buffer.toString();
        }
        //print('newHtmlText=$newHtmlText');
      }

      // generate plain text from HTML code:
      var plainText = newHtmlText.replaceAll(htmlTagRegex, '');
      if (mb.originalMessage != null) {
        final originalPlainText = mb.originalMessage.decodeTextPlainPart();
        if (originalPlainText != null) {
          if (widget.data.action == ComposeAction.forward) {
            final forwardHeader = MessageBuilder.fillTemplate(
                MailConventions.defaultForwardHeaderTemplate,
                mb.originalMessage);
            plainText += forwardHeader + originalPlainText;
          } else if (widget.data.action == ComposeAction.answer) {
            final replyHeader = MessageBuilder.fillTemplate(
                MailConventions.defaultForwardHeaderTemplate,
                mb.originalMessage);
            plainText += '\r\n' +
                MessageBuilder.quotePlainText(replyHeader, originalPlainText);
          }
        }
      }
      final textPartBuilder = mb.hasAttachments
          ? mb.getPart(MediaSubtype.multipartAlternative) ??
              mb.addPart(
                  mediaSubtype: MediaSubtype.multipartAlternative, insert: true)
          : mb;
      if (!mb.hasAttachments) {
        mb.setContentType(
            MediaType.fromSubtype(MediaSubtype.multipartAlternative));
      }
      final plainTextBuilder = textPartBuilder.getTextPlainPart();
      if (plainTextBuilder != null) {
        plainTextBuilder.text = plainText;
      } else {
        textPartBuilder.addTextPlain(plainText);
      }
      final fullHtmlMessageText =
          await _editorApi.getFullHtml(content: htmlText);
      final htmlTextBuilder = textPartBuilder.getTextHtmlPart();
      if (htmlTextBuilder != null) {
        htmlTextBuilder.text = fullHtmlMessageText;
      } else {
        textPartBuilder.addTextHtml(fullHtmlMessageText);
      }
    }
  }

  Future<MimeMessage> buildMimeMessage(MailClient mailClient) async {
    await populateMessageBuilder();
    final mb = widget.data.messageBuilder;
    _usedTextEncoding = TransferEncoding.automatic;
    final mimeMessage = mb.buildMimeMessage();
    return mimeMessage;
  }

  Future<MailClient> getMailClient() {
    return locator<MailService>().getClientFor(from.account);
  }

  Future<void> send(AppLocalizations localizations) async {
    locator<NavigationService>().pop();
    final mailClient = await getMailClient();
    final mimeMessage = await buildMimeMessage(mailClient);
    //TODO enable global busy indicator
    //TODO check first if message can be sent or catch errors
    try {
      final append = !from.account.addsSentMailAutomatically;
      final use8Bit = (_usedTextEncoding == TransferEncoding.eightBit);
      await mailClient.sendMessage(
        mimeMessage,
        from: from.account.fromAddress,
        appendToSent: append,
        use8BitEncoding: use8Bit,
      );
      locator<ScaffoldMessengerService>()
          .showTextSnackBar(localizations.composeMailSendSuccess);
    } on MailException catch (e, s) {
      //TODO latest here persist the mail for further retries in the future
      print('Unable to send or append mail: $e $s');
      locator<DialogService>().showTextDialog(context, localizations.errorTitle,
          localizations.composeSendErrorInfo(e.toString()));
      return;
    }
    //TODO disable global busy indicator
    var storeFlags = true;
    final originalMessage = widget.data.originalMessage;
    switch (widget.data.action) {
      case ComposeAction.answer:
        originalMessage.isAnswered = true;
        break;
      case ComposeAction.forward:
        originalMessage.isForwarded = true;
        break;
      case ComposeAction.newMessage:
        storeFlags = false;
        // no action to do
        break;
    }
    if (storeFlags) {
      try {
        await mailClient.store(
            MessageSequence.fromMessage(originalMessage.mimeMessage),
            originalMessage.mimeMessage.flags,
            action: StoreAction.replace);
      } catch (e, s) {
        print('Unable to update message flags: $e $s'); // otherwise ignore

      }
    } else if (originalMessage != null &&
        originalMessage.mimeMessage.hasFlag(MessageFlags.draft)) {
      // delete draft message:
      try {
        final source = originalMessage.source;
        source.remove(originalMessage);
        await mailClient.flagMessage(originalMessage.mimeMessage,
            isDeleted: true);
      } catch (e, s) {
        print('Unable to update message flags: $e $s'); // otherwise ignore

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
    final localizations = AppLocalizations.of(context);
    final titleText = widget.data.action == ComposeAction.answer
        ? localizations.composeTitleReply
        : widget.data.action == ComposeAction.forward
            ? localizations.composeTitleForward
            : localizations.composeTitleNew;
    return WillPopScope(
      onWillPop: () async {
        // let it pop but show snackbar to return:
        await populateMessageBuilder(storeHtmlForResume: true);
        locator<ScaffoldMessengerService>().showTextSnackBar(
            localizations.composeLeftByMistake,
            undo: returnToCompose);
        return true;
      },
      child: Scaffold(
        drawer: AppDrawer(),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: Text(titleText),
              floating: false,
              pinned: true,
              stretch: true,
              actions: [
                AddAttachmentPopupButton(
                  messageBuilder: widget.data.messageBuilder,
                  update: () => setState(() {}),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => send(localizations),
                ),
                PopupMenuButton<_OverflowMenuChoice>(
                  onSelected: (result) {
                    switch (result) {
                      case _OverflowMenuChoice.showSourceCode:
                        showSourceCode();
                        break;
                      case _OverflowMenuChoice.saveAsDraft:
                        saveAsDraft();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<_OverflowMenuChoice>(
                      value: _OverflowMenuChoice.saveAsDraft,
                      child: Text(localizations.composeSaveDraftAction),
                    ),
                    PopupMenuItem<_OverflowMenuChoice>(
                      value: _OverflowMenuChoice.showSourceCode,
                      child: Text(localizations.viewSourceAction),
                    ),
                  ],
                ),
              ], // actions
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.detailsHeaderFrom,
                        style: Theme.of(context).textTheme?.caption),
                    DropdownButton<Sender>(
                      isExpanded: true,
                      items: senders
                          .map(
                            (s) => DropdownMenuItem<Sender>(
                              value: s,
                              child: Text(
                                s.isPlaceHolderForPlusAlias
                                    ? localizations.composeCreatePlusAliasAction
                                    : s.toString(),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (s) async {
                        if (s.isPlaceHolderForPlusAlias) {
                          final index = senders.indexOf(s);
                          s = locator<MailService>()
                              .generateRandomPlusAliasSender(s);
                          setState(() {
                            senders.insert(index, s);
                          });
                        }
                        widget.data.messageBuilder.from = [s.address];
                        setState(() {
                          from = s;
                        });
                      },
                      value: from,
                      hint: Text(localizations.composeSenderHint),
                    ),
                    TextField(
                      controller: _toController,
                      autofocus: _focus == _Autofocus.to,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: localizations.detailsHeaderTo,
                        hintText: localizations.composeRecipientHint,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              child: Text(localizations.detailsHeaderCc),
                              onPressed: () => setState(
                                () => _isCcBccVisible = !_isCcBccVisible,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.contacts),
                              onPressed: () => _pickContact(_toController),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isCcBccVisible) ...{
                      TextField(
                        controller: _ccController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: localizations.detailsHeaderCc,
                          hintText: localizations.composeRecipientHint,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.contacts),
                            onPressed: () => _pickContact(_ccController),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _bccController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: localizations.detailsHeaderBcc,
                          hintText: localizations.composeRecipientHint,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.contacts),
                            onPressed: () => _pickContact(_bccController),
                          ),
                        ),
                      ),
                    },
                    TextField(
                      controller: _subjectController,
                      autofocus: _focus == _Autofocus.subject,
                      decoration: InputDecoration(
                        labelText: localizations.composeSubjectLabel,
                        hintText: localizations.composeSubjectHint,
                      ),
                    ),
                    if (widget.data.messageBuilder.attachments.isNotEmpty ||
                        (_downloadAttachmentsFuture != null)) ...{
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: AttachmentComposeBar(
                            composeData: widget.data,
                            isDownloading:
                                (_downloadAttachmentsFuture != null)),
                      ),
                      Divider(
                        color: Colors.grey,
                      )
                    },
                  ],
                ),
              ),
            ),
            if (_editorApi != null) ...{
              SliverHeaderHtmlEditorControls(editorApi: _editorApi),
            },
            SliverToBoxAdapter(
              child: FutureBuilder<String>(
                future: loadMailTextFuture,
                builder: (widget, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return Center(child: CircularProgressIndicator());
                      break;
                    case ConnectionState.done:
                      final text = snapshot.data ?? '<p></p>';
                      return HtmlEditor(
                        onCreated: (api) {
                          setState(() {
                            _editorApi = api;
                          });
                        },
                        initialContent: text,
                      );
                      break;
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initRecipient(
      List<MailAddress> addresses, TextEditingController textController) {
    if (addresses?.isEmpty ?? true) {
      textController.text = '';
    } else {
      textController.text = addresses.map((a) => a.email).join('; ');
      textController.selection =
          TextSelection.collapsed(offset: textController.text.length);
    }
  }

  void showSourceCode() async {
    final mailClient = await locator<MailService>().getClientFor(from.account);
    final mime = await buildMimeMessage(mailClient);
    locator<NavigationService>().push(Routes.sourceCode, arguments: mime);
  }

  Future addAttachment() async {
    final added =
        await AttachmentComposeBar.addAttachmentTo(widget.data.messageBuilder);
    if (added) {
      setState(() {});
    }
  }

  Future<void> saveAsDraft() async {
    locator<NavigationService>().pop();
    final localizations = locator<I18nService>().localizations;
    final mailClient = await locator<MailService>().getClientFor(from.account);
    final mime = await buildMimeMessage(mailClient);
    try {
      await mailClient.saveDraftMessage(mime);
      locator<ScaffoldMessengerService>()
          .showTextSnackBar(localizations.composeMessageSavedAsDraft);
      final originalMessage = widget.data.originalMessage;
      if (originalMessage != null) {
        await Future.delayed(const Duration(milliseconds: 20));
        originalMessage.source.remove(originalMessage);
        final originalMime = widget.data.messageBuilder.originalMessage;
        if (originalMime != null && originalMime.hasFlag(MessageFlags.draft)) {
          // delete previous draft message:
          try {
            await mailClient.flagMessage(originalMime, isDeleted: true);
          } catch (e, s) {
            print('(ignored) unable to delete previous draft message $e $s');
          }
        }
      }
    } catch (e, s) {
      print('unable to save draft message $e $s');
      locator<DialogService>().showTextDialog(context, localizations.errorTitle,
          localizations.composeMessageSavedAsDraftErrorInfo(e.toString()),
          actions: [
            TextButton(
              child: Text(localizations.actionCancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(localizations
                  .composeContinueEditingWhenDraftCannotBeSavedAction),
              onPressed: returnToCompose,
            ),
          ]);
    }
  }

  void returnToCompose() {
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: _resumeComposeData);
  }

  void _pickContact(TextEditingController textController) async {
    final contact =
        await FlutterContactPicker.pickEmailContact(askForPermission: true);
    if (contact != null) {
      if (textController.text.isNotEmpty) {
        textController.text += '; ' + contact.email.email;
      } else {
        textController.text = contact.email.email;
      }
      textController.selection =
          TextSelection.collapsed(offset: textController.text.length);
    }
  }
}

class _HtmlGenerationArguments {
  final String quoteTemplate;
  final MimeMessage mimeMessage;
  final bool blockExternalImages;
  final String emptyMessageText;
  final int maxImageWidth;
  _HtmlGenerationArguments(this.quoteTemplate, this.mimeMessage,
      this.blockExternalImages, this.emptyMessageText, this.maxImageWidth);
}
