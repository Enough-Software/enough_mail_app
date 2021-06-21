import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/shared_data.dart';
import 'package:enough_mail_app/services/app_service.dart';
import 'package:enough_mail_app/services/contact_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_mail_app/widgets/editor_extensions.dart';
import 'package:enough_mail_app/widgets/inherited_widgets.dart';
import 'package:enough_mail_app/widgets/recipient_input_field.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/sender.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_mail_app/widgets/attachment_compose_bar.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart' show IterableExtension;
import '../locator.dart';
import '../routes.dart';

class ComposeScreen extends StatefulWidget {
  final ComposeData data;
  ComposeScreen({Key? key, required this.data}) : super(key: key);

  @override
  _ComposeScreenState createState() => _ComposeScreenState();
}

enum _OverflowMenuChoice { showSourceCode, saveAsDraft, requestReadReceipt }
enum _Autofocus { to, subject, text }

class _ComposeScreenState extends State<ComposeScreen> {
  late List<MailAddress> _toRecipients;
  late List<MailAddress> _ccRecipients;
  late List<MailAddress> _bccRecipients;
  TextEditingController _subjectController = TextEditingController();
  late Sender _from;
  late List<Sender> _senders;
  _Autofocus? _focus;
  bool _isCcBccVisible = false;
  TransferEncoding? _usedTextEncoding;
  Future<String>? loadMailTextFuture;
  HtmlEditorApi? _editorApi;
  Future? _downloadAttachmentsFuture;
  ComposeData? _resumeComposeData;
  bool _isReadReceiptRequested = false;

  @override
  void initState() {
    locator<AppService>().onSharedData = _onSharedData;
    final mb = widget.data.messageBuilder;
    _toRecipients = mb.to ?? [];
    _ccRecipients = mb.cc ?? [];
    _bccRecipients = mb.bcc ?? [];
    _isCcBccVisible = _ccRecipients.isNotEmpty || _bccRecipients.isNotEmpty;
    _subjectController.text = mb.subject ?? '';
    _focus = (_toRecipients.isEmpty && _ccRecipients.isEmpty)
        ? _Autofocus.to
        : (_subjectController.text.isEmpty)
            ? _Autofocus.subject
            : _Autofocus.text;
    _senders = locator<MailService>().getSenders();
    final currentAccount = locator<MailService>().currentAccount!;
    if (mb.from == null) {
      mb.from = [currentAccount.fromAddress];
    }
    final senderEmail = mb.from?.first.email.toLowerCase();
    var from = _senders
        .firstWhereOrNull((s) => s.address.email.toLowerCase() == senderEmail);
    if (from == null) {
      from = Sender(mb.from!.first, currentAccount);
      _senders.insert(0, from);
    }
    _from = from;
    _checkAccountContactManager(_from.account);
    if (widget.data.resumeHtmlText != null) {
      loadMailTextFuture = _loadMailTextFromComposeData();
    } else {
      loadMailTextFuture = _loadMailTextFromMessage();
    }
    final future = widget.data.future;
    if (future != null) {
      _downloadAttachmentsFuture = future;
      future.then((value) {
        setState(() {
          _downloadAttachmentsFuture = null;
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    locator<AppService>().onSharedData = null;
    super.dispose();
  }

  Future<String> _loadMailTextFromComposeData() {
    return Future.value(widget.data.resumeHtmlText);
  }

  String get _signature => locator<SettingsService>()
      .getSignatureHtml(_from.account, widget.data.action);

  Future<String> _loadMailTextFromMessage() async {
    // find out signature:
    final mb = widget.data.messageBuilder;
    if (mb.originalMessage == null) {
      final html = '<p>${mb.text ?? '&nbsp;'}</p>$_signature';
      return html;
    } else {
      final blockExternalImages = false;
      final emptyMessageText =
          locator<I18nService>().localizations!.composeEmptyMessage;
      final maxImageWidth = 300;
      if (widget.data.action == ComposeAction.newMessage) {
        // continue with draft:
        final args = _HtmlGenerationArguments(null, mb.originalMessage,
            blockExternalImages, emptyMessageText, maxImageWidth);
        final html = await compute(_generateDraftHtmlImpl, args) + _signature;
        return html;
      }
      final quoteTemplate = widget.data.action == ComposeAction.answer
          ? MailConventions.defaultReplyHeaderTemplate
          : widget.data.action == ComposeAction.forward
              ? MailConventions.defaultForwardHeaderTemplate
              : MailConventions.defaultReplyHeaderTemplate;
      final args = _HtmlGenerationArguments(quoteTemplate, mb.originalMessage,
          blockExternalImages, emptyMessageText, maxImageWidth);
      final html = await compute(_generateQuoteHtmlImpl, args) + _signature;
      return html;
    }
  }

  static String _generateQuoteHtmlImpl(_HtmlGenerationArguments args) {
    final html = args.mimeMessage!.quoteToHtml(
      quoteHeaderTemplate: args.quoteTemplate,
      blockExternalImages: args.blockExternalImages,
      emptyMessageText: args.emptyMessageText,
      maxImageWidth: args.maxImageWidth,
    );
    return html;
  }

  static String _generateDraftHtmlImpl(_HtmlGenerationArguments args) {
    final html = args.mimeMessage!.transformToHtml(
        emptyMessageText: args.emptyMessageText,
        maxImageWidth: args.maxImageWidth,
        blockExternalImages: args.blockExternalImages);
    return html;
  }

  Future<void> _populateMessageBuilder(
      {bool storeHtmlForResume = false}) async {
    final mb = widget.data.messageBuilder;
    mb.to = _toRecipients;
    mb.cc = _ccRecipients;
    mb.bcc = _bccRecipients;
    mb.subject = _subjectController.text;

    final htmlText = await _editorApi!.getText();
    _resumeComposeData = widget.data.resume(htmlText);
    if (storeHtmlForResume) {
      return;
    } else {
      final plainText = HtmlToPlainTextConverter.convert(htmlText);

      final textPartBuilder = mb.hasAttachments
          ? mb.getPart(MediaSubtype.multipartAlternative, recursive: false) ??
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
          await _editorApi!.getFullHtml(content: htmlText);
      final htmlTextBuilder = textPartBuilder.getTextHtmlPart();
      if (htmlTextBuilder != null) {
        htmlTextBuilder.text = fullHtmlMessageText;
      } else {
        textPartBuilder.addTextHtml(fullHtmlMessageText);
      }
    }
  }

  Future<MimeMessage> _buildMimeMessage(MailClient mailClient) async {
    await _populateMessageBuilder();
    final mb = widget.data.messageBuilder;
    _usedTextEncoding = TransferEncoding.automatic;
    final mimeMessage = mb.buildMimeMessage();
    return mimeMessage;
  }

  Future<MailClient> _getMailClient() {
    return locator<MailService>().getClientFor(_from.account);
  }

  Future<void> _send(AppLocalizations localizations) async {
    locator<NavigationService>().pop();
    final mailClient = await _getMailClient();
    final mimeMessage = await _buildMimeMessage(mailClient);
    try {
      final append = !_from.account.addsSentMailAutomatically;
      final use8Bit = (_usedTextEncoding == TransferEncoding.eightBit);
      await mailClient.sendMessage(
        mimeMessage,
        from: _from.account.fromAddress,
        appendToSent: append,
        use8BitEncoding: use8Bit,
      );
      locator<ScaffoldMessengerService>()
          .showTextSnackBar(localizations.composeMailSendSuccess);
    } catch (e, s) {
      print('Unable to send or append mail: $e $s');
      // this state's context is now invalid because this widget is not mounted anymore
      final currentContext = locator<NavigationService>().currentContext!;
      final message = (e is MailException) ? e.message! : e.toString();
      DialogHelper.showTextDialog(
        currentContext,
        localizations.errorTitle,
        localizations.composeSendErrorInfo(message),
        actions: [
          PlatformTextButton(
            child: ButtonText(localizations.actionCancel),
            onPressed: () => Navigator.of(currentContext).pop(),
          ),
          PlatformTextButton(
            child: ButtonText(localizations.composeContinueEditingAction),
            onPressed: () {
              Navigator.of(currentContext).pop();
              _returnToCompose();
            },
          ),
        ],
      );
      return;
    }
    final action = widget.data.action;
    final storeFlags = action != ComposeAction.newMessage;
    if (storeFlags) {
      for (final originalMessage in widget.data.originalMessages!) {
        if (action == ComposeAction.answer) {
          originalMessage!.isAnswered = true;
        } else {
          originalMessage!.isForwarded = true;
        }
        try {
          await mailClient.store(
              MessageSequence.fromMessage(originalMessage.mimeMessage!),
              originalMessage.mimeMessage!.flags!,
              action: StoreAction.replace);
        } catch (e, s) {
          print('Unable to update message flags: $e $s'); // otherwise ignore
        }
      }
    } else if ((widget.data.originalMessage != null) &&
        widget.data.originalMessage!.mimeMessage!.hasFlag(MessageFlags.draft)) {
      // delete draft message:
      try {
        final originalMessage = widget.data.originalMessage!;
        final source = originalMessage.source;
        source.remove(originalMessage);
        await mailClient.flagMessage(originalMessage.mimeMessage!,
            isDeleted: true);
      } catch (e, s) {
        print('Unable to update message flags: $e $s'); // otherwise ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final titleText = widget.data.action == ComposeAction.answer
        ? localizations.composeTitleReply
        : widget.data.action == ComposeAction.forward
            ? localizations.composeTitleForward
            : localizations.composeTitleNew;
    return WillPopScope(
      onWillPop: () async {
        // let it pop but show snackbar to return:
        await _populateMessageBuilder(storeHtmlForResume: true);
        locator<ScaffoldMessengerService>().showTextSnackBar(
            localizations.composeLeftByMistake,
            undo: _returnToCompose);
        return true;
      },
      child: MessageWidget(
        message: widget.data.originalMessage,
        child: PlatformScaffold(
          material: (context, platform) =>
              MaterialScaffoldData(drawer: AppDrawer()),
          body: CustomScrollView(
            slivers: [
              PlatformSliverAppBar(
                title: Text(titleText),
                floating: false,
                pinned: true,
                stretch: true,
                actions: [
                  AddAttachmentPopupButton(
                    messageBuilder: widget.data.messageBuilder,
                    update: () => setState(() {}),
                  ),
                  PlatformIconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _send(localizations),
                  ),
                  PlatformPopupMenuButton<_OverflowMenuChoice>(
                    onSelected: (result) {
                      switch (result) {
                        case _OverflowMenuChoice.showSourceCode:
                          _showSourceCode();
                          break;
                        case _OverflowMenuChoice.saveAsDraft:
                          _saveAsDraft();
                          break;
                        case _OverflowMenuChoice.requestReadReceipt:
                          _requestReadReceipt();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PlatformPopupMenuItem<_OverflowMenuChoice>(
                        value: _OverflowMenuChoice.saveAsDraft,
                        child: Text(localizations.composeSaveDraftAction),
                      ),
                      PlatformPopupMenuItem<_OverflowMenuChoice>(
                        value: _OverflowMenuChoice.requestReadReceipt,
                        child:
                            Text(localizations.composeRequestReadReceiptAction),
                      ),
                      if (locator<SettingsService>()
                          .settings
                          .enableDeveloperMode) ...{
                        PlatformPopupMenuItem<_OverflowMenuChoice>(
                          value: _OverflowMenuChoice.showSourceCode,
                          child: Text(localizations.viewSourceAction),
                        ),
                      }
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
                          style: Theme.of(context).textTheme.caption),
                      PlatformDropdownButton<Sender>(
                        isExpanded: true,
                        items: _senders
                            .map(
                              (s) => DropdownMenuItem<Sender>(
                                value: s,
                                child: Text(
                                  s.toString(),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (s) async {
                          final builder = widget.data.messageBuilder;

                          builder.from = [s!.address];
                          final lastSignature = _signature;
                          _from = s;
                          final newSignature = _signature;
                          if (newSignature != lastSignature) {
                            _editorApi!.replaceAll(lastSignature, newSignature);
                          }
                          if (_isReadReceiptRequested) {
                            builder.requestReadReceipt(
                                recipient: _from.address);
                          }
                          setState(() {});

                          _checkAccountContactManager(_from.account);
                        },
                        value: _from,
                        hint: Text(localizations.composeSenderHint),
                      ),
                      RecipientInputField(
                        contactManager: _from.account.contactManager,
                        addresses: _toRecipients,
                        autofocus: _focus == _Autofocus.to,
                        labelText: localizations.detailsHeaderTo,
                        hintText: localizations.composeRecipientHint,
                        additionalSuffixIcon: PlatformTextButton(
                          child: ButtonText(localizations.detailsHeaderCc),
                          onPressed: () => setState(
                            () => _isCcBccVisible = !_isCcBccVisible,
                          ),
                        ),
                      ),
                      if (_isCcBccVisible) ...{
                        RecipientInputField(
                          addresses: _ccRecipients,
                          contactManager: _from.account.contactManager,
                          labelText: localizations.detailsHeaderCc,
                          hintText: localizations.composeRecipientHint,
                        ),
                        RecipientInputField(
                          addresses: _bccRecipients,
                          contactManager: _from.account.contactManager,
                          labelText: localizations.detailsHeaderBcc,
                          hintText: localizations.composeRecipientHint,
                        ),
                      },
                      DecoratedPlatformTextField(
                        controller: _subjectController,
                        autofocus: _focus == _Autofocus.subject,
                        decoration: InputDecoration(
                          labelText: localizations.composeSubjectLabel,
                          hintText: localizations.composeSubjectHint,
                        ),
                        cupertinoShowLabel: false,
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
              if (_isReadReceiptRequested) ...{
                SliverToBoxAdapter(
                  child: PlatformCheckboxListTile(
                    value: true,
                    title: Text(localizations.composeRequestReadReceiptAction),
                    onChanged: (value) {
                      _removeReadReceiptRequest();
                    },
                  ),
                ),
              },
              if (_editorApi != null) ...{
                SliverHeaderHtmlEditorControls(
                  editorApi: _editorApi,
                  suffix: EditorArtExtensionButton(editorApi: _editorApi!),
                ),
              },
              SliverToBoxAdapter(
                child: FutureBuilder<String>(
                  future: loadMailTextFuture,
                  builder: (widget, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return Center(child: PlatformProgressIndicator());
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
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceCode() async {
    final mailClient = await locator<MailService>().getClientFor(_from.account);
    final mime = await _buildMimeMessage(mailClient);
    locator<NavigationService>().push(Routes.sourceCode, arguments: mime);
  }

  Future<void> _saveAsDraft() async {
    locator<NavigationService>().pop();
    final localizations = locator<I18nService>().localizations!;
    final mailClient = await locator<MailService>().getClientFor(_from.account);
    final mime = await _buildMimeMessage(mailClient);
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
      final currentContext = locator<NavigationService>().currentContext!;
      DialogHelper.showTextDialog(
        currentContext,
        localizations.errorTitle,
        localizations.composeMessageSavedAsDraftErrorInfo(e.toString()),
        actions: [
          PlatformTextButton(
            child: ButtonText(localizations.actionCancel),
            onPressed: () => Navigator.of(currentContext).pop(),
          ),
          PlatformTextButton(
            child: ButtonText(localizations.composeContinueEditingAction),
            onPressed: () {
              Navigator.of(currentContext).pop();
              _returnToCompose();
            },
          ),
        ],
      );
    }
  }

  void _requestReadReceipt() {
    widget.data.messageBuilder.requestReadReceipt(recipient: _from.address);
    setState(() {
      _isReadReceiptRequested = true;
    });
  }

  void _removeReadReceiptRequest() {
    widget.data.messageBuilder.removeReadReceiptRequest();
    setState(() {
      _isReadReceiptRequested = false;
    });
  }

  void _returnToCompose() {
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: _resumeComposeData);
  }

  void _checkAccountContactManager(Account account) {
    if (account.contactManager == null) {
      locator<ContactService>().getForAccount(account).then((value) {
        setState(() {});
      });
    }
  }

  Future _onSharedData(List<SharedData> sharedData) {
    final firstData = sharedData.first;
    if (firstData is SharedMailto) {
      //TODO add the recipients, set the subject, set the text?
    } else {
      final api = _editorApi;
      if (api != null) {
        for (final data in sharedData) {
          data.addToMessageBuilder(widget.data.messageBuilder);
          data.addToEditor(api);
        }
      }
    }
    return Future.value();
  }
}

class _HtmlGenerationArguments {
  final String? quoteTemplate;
  final MimeMessage? mimeMessage;
  final bool blockExternalImages;
  final String emptyMessageText;
  final int maxImageWidth;
  _HtmlGenerationArguments(this.quoteTemplate, this.mimeMessage,
      this.blockExternalImages, this.emptyMessageText, this.maxImageWidth);
}
