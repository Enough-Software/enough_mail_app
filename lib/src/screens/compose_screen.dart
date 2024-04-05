import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:enough_text_editor/enough_text_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../contact/provider.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../mail/provider.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../models/sender.dart';
import '../routes/routes.dart';
import '../scaffold_messenger/service.dart';
import '../settings/provider.dart';
import '../share/model.dart';
import '../share/provider.dart';
import '../util/localized_dialog_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/attachment_compose_bar.dart';
import '../widgets/editor_extensions.dart';
import '../widgets/recipient_input_field.dart';

enum _OverflowMenuChoice {
  showSourceCode,
  saveAsDraft,
  requestReadReceipt,
  convertToPlainTextEditor,
  convertToHtmlEditor
}

enum _Autofocus { to, subject, text }

/// A dropdown to select the sender
class SenderDropdown extends HookConsumerWidget {
  /// Creates a new [SenderDropdown] with the given [onChanged]
  const SenderDropdown({
    super.key,
    required this.onChanged,
    this.from,
  });

  /// Callback when the selected sender changes
  final ValueChanged<Sender> onChanged;

  /// Optional list of from sender addresses
  final List<MailAddress>? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(RV): consider adding first from as sender
    final senders = ref.watch(sendersProvider);

    Sender getInitialSender() {
      final from = this.from;
      if (from != null && from.isNotEmpty) {
        final senderEmail = from.first.email.toLowerCase();
        final sender = senders.firstWhereOrNull(
          (s) => s.address.email.toLowerCase() == senderEmail,
        );
        if (sender != null) {
          return sender;
        }
      }
      final defaultSender = ref.read(settingsProvider).defaultSender;
      if (defaultSender != null) {
        final senderEmail = defaultSender.email.toLowerCase();
        final sender = senders.firstWhereOrNull(
          (s) => s.address.email.toLowerCase() == senderEmail,
        );
        if (sender != null) {
          return sender;
        }
      }
      final account = ref.read(currentRealAccountProvider);
      if (account != null) {
        final senderEmail = account.fromAddress.email.toLowerCase();
        final sender = senders.firstWhereOrNull(
          (s) => s.address.email.toLowerCase() == senderEmail,
        );
        if (sender != null) {
          return sender;
        }
      }

      return senders.first;
    }

    final senderState = useState(getInitialSender());

    return PlatformDropdownButton<Sender>(
      material: (context, platform) => MaterialDropdownButtonData(
        isExpanded: true,
      ),
      items: senders
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
        if (s != null) {
          senderState.value = s;
          onChanged(s);
        }
      },
      value: senderState.value,
      hint: Text(ref.text.composeSenderHint),
    );
  }
}

/// Compose a new email message
class ComposeScreen extends ConsumerStatefulWidget {
  /// Creates a new [ComposeScreen] with the given [ComposeData
  const ComposeScreen({super.key, required this.data});

  /// The initial data for composing the message
  final ComposeData data;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  late List<MailAddress> _toRecipients;
  late List<MailAddress> _ccRecipients;
  late List<MailAddress> _bccRecipients;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _plainTextController = TextEditingController();
  late Sender _from;
  late List<Sender> _senders;
  _Autofocus? _focus;
  bool _isCcBccVisible = false;
  Future<String>? _loadMailTextFuture;
  HtmlEditorApi? _htmlEditorApi;
  Future? _downloadAttachmentsFuture;
  ComposeData? _resumeComposeData;
  bool _isReadReceiptRequested = false;
  late ComposeMode _composeMode;
  late RealAccount _realAccount;

  TextEditorApi? _plainTextEditorApi;

  @override
  void didChangeDependencies() {
    onSharedData = _onSharedData;
    _composeMode = widget.data.composeMode;
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
    _senders = ref.read(sendersProvider);
    final currentAccount = ref.read(currentRealAccountProvider)!;
    _realAccount = currentAccount;
    final defaultSender = ref.read(settingsProvider).defaultSender;
    final mbFrom = mb.from ?? [defaultSender ?? currentAccount.fromAddress];
    mb.from ??= mbFrom;
    Sender? from;
    if (mbFrom.first == defaultSender) {
      from = _senders
          .firstWhereOrNull((sender) => sender.address == defaultSender);
    } else {
      final senderEmail = mb.from?.first.email.toLowerCase();
      from = _senders.firstWhereOrNull(
        (s) => s.address.email.toLowerCase() == senderEmail,
      );
    }
    if (from == null) {
      from = Sender(mbFrom.first, currentAccount);
      _senders = [from, ..._senders];
    }
    _from = from;
    _checkAccountContactManager(_from.account);
    _loadMailTextFuture = widget.data.resumeText != null
        ? _loadMailTextFromComposeData()
        : _loadMailTextFromMessage();
    final future = widget.data.future;
    if (future != null) {
      _downloadAttachmentsFuture = future;
      future.then((value) {
        setState(() {
          _downloadAttachmentsFuture = null;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _plainTextController.dispose();
    onSharedData = null;
    super.dispose();
  }

  Future<String> _loadMailTextFromComposeData() =>
      Future.value(widget.data.resumeText);

  String get _signature => ref.read(settingsProvider.notifier).getSignatureHtml(
        _from.account,
        widget.data.action,
        ref.text.localeName,
      );

  Future<String> _loadMailTextFromMessage() async {
    final signature = _signature;
    // find out signature:
    final mb = widget.data.messageBuilder;
    if (mb.originalMessage == null) {
      if (_composeMode == ComposeMode.html) {
        // cSpell:ignore nbsp
        final html = '<p>${mb.text ?? '&nbsp;'}</p>$signature';

        return html;
      } else {
        return '${mb.text ?? ''}\n$signature';
      }
    } else {
      const blockExternalImages = false;
      final emptyMessageText = ref.text.composeEmptyMessage;
      const maxImageWidth = 300;
      if (widget.data.action == ComposeAction.newMessage) {
        // continue with draft:
        if (_composeMode == ComposeMode.html) {
          final args = _HtmlGenerationArguments(
            null,
            mb.originalMessage,
            blockExternalImages,
            emptyMessageText,
            maxImageWidth,
          );
          final html = await compute(_generateDraftHtmlImpl, args) + signature;

          return html;
        } else {
          final text =
              '${mb.originalMessage?.decodeTextPlainPart() ?? emptyMessageText}'
              '\n$signature';

          return text;
        }
      }

      // TODO(RV): localize quote templates
      final quoteTemplate = widget.data.action == ComposeAction.answer
          ? MailConventions.defaultReplyHeaderTemplate
          : widget.data.action == ComposeAction.forward
              ? MailConventions.defaultForwardHeaderTemplate
              : MailConventions.defaultReplyHeaderTemplate;
      if (_composeMode == ComposeMode.html) {
        final args = _HtmlGenerationArguments(
          quoteTemplate,
          mb.originalMessage,
          blockExternalImages,
          emptyMessageText,
          maxImageWidth,
        );
        final html = await compute(_generateQuoteHtmlImpl, args) + signature;

        return html;
      } else {
        final original = mb.originalMessage;
        if (original != null) {
          final header = MessageBuilder.fillTemplate(quoteTemplate, original);
          final plainText = original.decodeTextPlainPart() ?? emptyMessageText;
          final text = MessageBuilder.quotePlainText(header, plainText);

          return '$text\n$signature';
        } else {
          return '\n$signature';
        }
      }
    }
  }

  static String _generateQuoteHtmlImpl(_HtmlGenerationArguments args) {
    final html = args.mimeMessage?.quoteToHtml(
      quoteHeaderTemplate: args.quoteTemplate,
      blockExternalImages: args.blockExternalImages,
      emptyMessageText: args.emptyMessageText,
      maxImageWidth: args.maxImageWidth,
    );

    return html ?? '';
  }

  static String _generateDraftHtmlImpl(_HtmlGenerationArguments args) {
    final html = args.mimeMessage?.transformToHtml(
      emptyMessageText: args.emptyMessageText,
      maxImageWidth: args.maxImageWidth,
      blockExternalImages: args.blockExternalImages,
    );

    return html ?? '';
  }

  Future<void> _populateMessageBuilder({
    bool storeComposeDataForResume = false,
  }) async {
    final mb = widget.data.messageBuilder
      ..to = _toRecipients
      ..cc = _ccRecipients
      ..bcc = _bccRecipients
      ..subject = _subjectController.text;

    final text = _composeMode == ComposeMode.html
        ? await _htmlEditorApi?.getText() ?? ''
        : _plainTextController.text;
    _resumeComposeData = widget.data.resume(text, composeMode: _composeMode);
    if (storeComposeDataForResume) {
      return;
    } else {
      if (_composeMode == ComposeMode.plainText) {
        // create a plain text mail
        if (mb.hasAttachments) {
          final builder = mb.getTextPlainPart();
          if (builder != null) {
            builder.text = text;
          } else {
            mb.addTextPlain(text);
          }
        } else {
          mb
            ..text = text
            ..setContentType(MediaType.textPlain);
        }
      } else {
        // create a normal mail with an HTML and a plain text part:
        final plainText = _convertToPlainText(text);

        final multipartAlternativeBuilder = mb.hasAttachments
            ? mb.getPart(MediaSubtype.multipartAlternative, recursive: false) ??
                mb.addPart(
                  mediaSubtype: MediaSubtype.multipartAlternative,
                  insert: true,
                )
            : mb;
        if (!mb.hasAttachments) {
          mb.setContentType(
            MediaType.fromSubtype(MediaSubtype.multipartAlternative),
          );
        }
        final plainTextBuilder = multipartAlternativeBuilder.getTextPlainPart();
        if (plainTextBuilder != null) {
          plainTextBuilder.text = plainText;
        } else {
          multipartAlternativeBuilder.addTextPlain(plainText);
        }
        final fullHtmlMessageText =
            await _htmlEditorApi?.getFullHtml(content: text) ?? '';
        final htmlTextBuilder = multipartAlternativeBuilder.getTextHtmlPart();
        if (htmlTextBuilder != null) {
          htmlTextBuilder.text = fullHtmlMessageText;
        } else {
          multipartAlternativeBuilder.addTextHtml(fullHtmlMessageText);
        }
      }
    }
  }

  Future<MimeMessage> _buildMimeMessage(MailClient mailClient) async {
    await _populateMessageBuilder();
    widget.data.finalize();
    final mb = widget.data.messageBuilder;
    if (mailClient.account.hasAttribute(RealAccount.attributeBccMyself)) {
      final myAddress = mailClient.account.fromAddress;
      final myEmail = myAddress.email;
      final bcc = mb.bcc;
      if (bcc == null || !bcc.any((address) => address.email == myEmail)) {
        if (bcc == null) {
          mb.bcc = [myAddress];
        } else {
          bcc.add(myAddress);
        }
      }
    }
    final mimeMessage = mb.buildMimeMessage();

    return mimeMessage;
  }

  MailClient _getMailClient() =>
      ref.read(mailClientSourceProvider(account: _realAccount));

  Future<void> _send(AppLocalizations localizations) async {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      final result = await LocalizedDialogHelper.askForConfirmation(
        ref,
        title: localizations.composeSubjectHint,
        query: localizations.composeWarningNoSubject,
        action: localizations.composeActionSentWithoutSubject,
      );
      if (result != true) {
        return;
      }
    }
    if (mounted) {
      context.pop();
    }
    final mailClient = _getMailClient();
    final mimeMessage = await _buildMimeMessage(mailClient);
    try {
      final append = !_from.account.addsSentMailAutomatically;
      await mailClient.sendMessage(
        mimeMessage,
        from: _from.account.fromAddress,
        appendToSent: append,
      );
      ScaffoldMessengerService.instance.showTextSnackBar(
        localizations,
        localizations.composeMailSendSuccess,
      );
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to send or append mail: $e $s');
      }
      // this state's context is now invalid because this widget is not
      // mounted anymore
      final currentContext = Routes.navigatorKey.currentContext;
      if (currentContext != null && currentContext.mounted) {
        final message =
            (e is MailException) ? e.message ?? e.toString() : e.toString();
        await LocalizedDialogHelper.showTextDialog(
          ref,
          localizations.errorTitle,
          localizations.composeSendErrorInfo(message),
          actions: [
            PlatformTextButton(
              onPressed: currentContext.pop,
              child: Text(localizations.actionCancel),
            ),
            PlatformTextButton(
              child: Text(localizations.composeContinueEditingAction),
              onPressed: () {
                currentContext.pop();
                _returnToCompose();
              },
            ),
          ],
        );
      }

      return;
    }
    final action = widget.data.action;
    final storeFlags = action != ComposeAction.newMessage;
    if (storeFlags) {
      for (final originalMessage
          in widget.data.originalMessages ?? const <Message?>[]) {
        if (originalMessage == null) {
          continue;
        }
        if (action == ComposeAction.answer) {
          originalMessage.isAnswered = true;
        } else {
          originalMessage.isForwarded = true;
        }
        try {
          await mailClient.store(
            MessageSequence.fromMessage(originalMessage.mimeMessage),
            originalMessage.mimeMessage.flags ?? [],
            action: StoreAction.replace,
          );
        } catch (e, s) {
          if (kDebugMode) {
            print('Unable to update message flags: $e $s'); // otherwise ignore
          }
        }
      }
    } else if (widget.data.originalMessage?.mimeMessage
            .hasFlag(MessageFlags.draft) ??
        false) {
      // delete draft message:
      try {
        final originalMessage = widget.data.originalMessage;
        if (originalMessage != null) {
          originalMessage.source.removeFromCache(originalMessage);
          await mailClient.flagMessage(
            originalMessage.mimeMessage,
            isDeleted: true,
          );
        }
      } catch (e, s) {
        if (kDebugMode) {
          print('Unable to update message flags: $e $s'); // otherwise ignore
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ref.text;
    final titleText = widget.data.action == ComposeAction.answer
        ? localizations.composeTitleReply
        : widget.data.action == ComposeAction.forward
            ? localizations.composeTitleForward
            : localizations.composeTitleNew;
    final htmlEditorApi = _htmlEditorApi;

    return WillPopScope(
      onWillPop: () async {
        await _populateMessageBuilder(storeComposeDataForResume: true);
        ScaffoldMessengerService.instance.showTextSnackBar(
          localizations,
          localizations.composeLeftByMistake,
          undo: _returnToCompose,
        );

        return Future.value(true);
      },
      // wait for https://github.com/flutter/flutter/issues/138525 before
      // switching to PopScope
      // onPopInvoked: (didPop) async {
      //   // let it pop but show snackbar to return:
      //   await _populateMessageBuilder(storeComposeDataForResume: true);
      //   ScaffoldMessengerService.instance.showTextSnackBar(
      //     localizations,
      //     localizations.composeLeftByMistake,
      //     undo: _returnToCompose,
      //   );
      // },
      child: PlatformScaffold(
        material: (context, platform) =>
            MaterialScaffoldData(drawer: const AppDrawer()),
        body: CustomScrollView(
          slivers: [
            EnoughPlatformSliverAppBar(
              title: Text(titleText),
              pinned: true,
              stretch: true,
              actions: [
                AddAttachmentPopupButton(
                  composeData: widget.data,
                  update: () => setState(
                    () {},
                  ),
                ),
                PlatformIconButton(
                  icon: const Icon(Icons.send),
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
                      case _OverflowMenuChoice.convertToPlainTextEditor:
                        _convertToPlainTextEditor();
                        break;
                      case _OverflowMenuChoice.convertToHtmlEditor:
                        _convertToHtmlEditor();
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
                    if (_composeMode == ComposeMode.html)
                      PlatformPopupMenuItem<_OverflowMenuChoice>(
                        value: _OverflowMenuChoice.convertToPlainTextEditor,
                        child: Text(
                          localizations.composeConvertToPlainTextEditorAction,
                        ),
                      )
                    else
                      PlatformPopupMenuItem<_OverflowMenuChoice>(
                        value: _OverflowMenuChoice.convertToHtmlEditor,
                        child: Text(
                          localizations.composeConvertToHtmlEditorAction,
                        ),
                      ),
                    if (ref.read(settingsProvider).enableDeveloperMode)
                      PlatformPopupMenuItem<_OverflowMenuChoice>(
                        value: _OverflowMenuChoice.showSourceCode,
                        child: Text(localizations.viewSourceAction),
                      ),
                  ],
                ),
              ], // actions
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.detailsHeaderFrom,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    // SenderDropdown(
                    //   from: widget.data.messageBuilder.from,
                    //   onChanged:
                    PlatformDropdownButton<Sender>(
                      material: (context, platform) =>
                          MaterialDropdownButtonData(
                        isExpanded: true,
                      ),
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
                        if (s != null) {
                          // (s) {
                          final builder = widget.data.messageBuilder
                            ..from = [s.address];
                          final lastSignature = _signature;
                          _from = s;
                          final newSignature = _signature;
                          if (newSignature != lastSignature) {
                            await _htmlEditorApi?.replaceAll(
                              lastSignature,
                              newSignature,
                            );
                          }
                          if (_isReadReceiptRequested) {
                            builder.requestReadReceipt(
                              recipient: _from.address,
                            );
                          }
                          ref.read(currentAccountProvider.notifier).state =
                              s.account;
                          setState(() {
                            _realAccount = s.account;
                          });

                          await _checkAccountContactManager(_from.account);
                        }
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
                        child: Text(localizations.detailsHeaderCc),
                        onPressed: () => setState(
                          () => _isCcBccVisible = !_isCcBccVisible,
                        ),
                      ),
                    ),
                    if (_isCcBccVisible) ...[
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
                    ],
                    TextEditor(
                      controller: _subjectController,
                      autofocus: _focus == _Autofocus.subject,
                      decoration: InputDecoration(
                        labelText: localizations.composeSubjectLabel,
                        hintText: localizations.composeSubjectHint,
                      ),
                      cupertinoShowLabel: false,
                    ),
                    if (widget.data.messageBuilder.attachments.isNotEmpty ||
                        (_downloadAttachmentsFuture != null)) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: AttachmentComposeBar(
                          composeData: widget.data,
                          isDownloading: _downloadAttachmentsFuture != null,
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_isReadReceiptRequested)
              SliverToBoxAdapter(
                child: PlatformCheckboxListTile(
                  value: true,
                  title: Text(localizations.composeRequestReadReceiptAction),
                  onChanged: (value) {
                    _removeReadReceiptRequest();
                  },
                ),
              ),
            if (_composeMode == ComposeMode.html && htmlEditorApi != null)
              SliverHeaderHtmlEditorControls(
                editorApi: htmlEditorApi,
                suffix: EditorArtExtensionButton(editorApi: htmlEditorApi),
              )
            else if (_composeMode == ComposeMode.plainText &&
                _plainTextEditorApi != null)
              SliverHeaderTextEditorControls(
                editorApi: _plainTextEditorApi,
              ),
            SliverToBoxAdapter(
              child: FutureBuilder<String>(
                future: _loadMailTextFuture,
                builder: (widget, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Center(child: PlatformProgressIndicator());
                    case ConnectionState.done:
                      if (_composeMode == ComposeMode.html) {
                        final text = snapshot.data ?? '<p></p>';

                        return HtmlEditor(
                          onCreated: (api) {
                            setState(() {
                              _htmlEditorApi = api;
                            });
                          },
                          enableDarkMode:
                              Theme.of(context).brightness == Brightness.dark,
                          initialContent: text,
                          minHeight: 400,
                        );
                      } else {
                        // compose mode is plainText
                        _plainTextController.text = snapshot.data ?? '';

                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextEditor(
                            controller: _plainTextController,
                            minLines: 10,
                            maxLines: null,
                            onCreated: (api) {
                              setState(() {
                                _plainTextEditorApi = api;
                              });
                            },
                          ),
                        );
                      }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSourceCode() async {
    final mailClient = _getMailClient();
    final mime = await _buildMimeMessage(mailClient);
    if (mounted) {
      unawaited(context.pushNamed(Routes.sourceCode, extra: mime));
    }
  }

  Future<void> _saveAsDraft() async {
    context.pop();
    final localizations = ref.text;
    final mailClient = _getMailClient();
    final mime = await _buildMimeMessage(mailClient);
    try {
      await mailClient.saveDraftMessage(mime);
      ScaffoldMessengerService.instance.showTextSnackBar(
        localizations,
        localizations.composeMessageSavedAsDraft,
      );
      final originalMessage = widget.data.originalMessage;
      if (originalMessage != null) {
        await Future.delayed(const Duration(milliseconds: 20));
        originalMessage.source.removeFromCache(originalMessage);
        final originalMime = widget.data.messageBuilder.originalMessage;
        if (originalMime != null && originalMime.hasFlag(MessageFlags.draft)) {
          // delete previous draft message:
          try {
            await mailClient.flagMessage(originalMime, isDeleted: true);
          } catch (e, s) {
            if (kDebugMode) {
              print('(ignored) unable to delete previous draft message $e $s');
            }
          }
        }
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('unable to save draft message $e $s');
      }
      final currentContext = Routes.navigatorKey.currentContext;
      if (currentContext != null && currentContext.mounted) {
        await LocalizedDialogHelper.showTextDialog(
          ref,
          localizations.errorTitle,
          localizations.composeMessageSavedAsDraftErrorInfo(e.toString()),
          actions: [
            PlatformTextButton(
              onPressed: currentContext.pop,
              child: Text(localizations.actionCancel),
            ),
            PlatformTextButton(
              child: Text(localizations.composeContinueEditingAction),
              onPressed: () {
                currentContext.pop();
                _returnToCompose();
              },
            ),
          ],
        );
      }
    }
  }

  void _requestReadReceipt() {
    widget.data.messageBuilder.requestReadReceipt(recipient: _from.address);
    setState(() {
      _isReadReceiptRequested = true;
    });
  }

  void _convertToPlainTextEditor() {
    final future = _htmlEditorApi?.getText() ?? Future.value('');
    setState(() {
      _loadMailTextFuture = future.then(_convertToPlainText);
      _composeMode = ComposeMode.plainText;
    });
  }

  void _convertToHtmlEditor() {
    final text = _plainTextController.text.replaceAll('\n', '<br/>');
    setState(() {
      _loadMailTextFuture = Future.value('<p>$text</p>');
      _composeMode = ComposeMode.html;
    });
  }

  void _removeReadReceiptRequest() {
    widget.data.messageBuilder.removeReadReceiptRequest();
    setState(() {
      _isReadReceiptRequested = false;
    });
  }

  void _returnToCompose() {
    final currentContext = Routes.navigatorKey.currentContext;
    if (currentContext != null && currentContext.mounted) {
      currentContext.pushNamed(
        Routes.mailCompose,
        extra: _resumeComposeData,
      );
    }
  }

  Future<void> _checkAccountContactManager(RealAccount account) async {
    final contactManager = account.contactManager;
    if (contactManager == null) {
      account.contactManager =
          await ref.read(contactsLoaderProvider(account: account).future);
      setState(() {});
    }
  }

  Future _onSharedData(List<SharedData> sharedData) {
    final firstData = sharedData.first;
    if (firstData is SharedMailto) {
      // TODO(RV): add the recipients, set the subject, set the text?
    } else {
      final api = _htmlEditorApi;
      if (api != null) {
        for (final data in sharedData) {
          data
            ..addToMessageBuilder(widget.data.messageBuilder)
            ..addToEditor(api);
        }
      }
    }

    return Future.value();
  }

  String _convertToPlainText(String htmlText) =>
      HtmlToPlainTextConverter.convert(htmlText);
}

class _HtmlGenerationArguments {
  _HtmlGenerationArguments(
    this.quoteTemplate,
    this.mimeMessage,
    this.blockExternalImages,
    this.emptyMessageText,
    this.maxImageWidth,
  );
  final String? quoteTemplate;
  final MimeMessage? mimeMessage;
  final bool blockExternalImages;
  final String emptyMessageText;
  final int maxImageWidth;
}
