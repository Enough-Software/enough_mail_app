import 'dart:async';
import 'dart:ui';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/widgets/attachment_chip.dart';
import 'package:enough_mail_app/widgets/mail_address_chip.dart';
import 'package:enough_mail_app/widgets/message_actions.dart';
import 'package:enough_mail_app/widgets/message_overview_content.dart';
import 'package:enough_mail_app/widgets/message_widget.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MessageDetailsScreen extends StatefulWidget {
  final Message message;
  const MessageDetailsScreen({Key key, @required this.message})
      : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

enum _OverflowMenuChoice { showContents, showSourceCode }

class _DetailsScreenState extends State<MessageDetailsScreen> {
  PageController _pageController;
  MessageSource source;
  Message current;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.message.sourceIndex);
    current = widget.message;
    source = current.source;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Message getMessage(int index) {
    if (current.sourceIndex == index) {
      return current;
    }
    current = source.getMessageAt(index);
    return current;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: source.size,
      itemBuilder: (context, index) => _MessageContent(getMessage(index)),
    );
  }
}

class _MessageContent extends StatefulWidget {
  final Message message;
  const _MessageContent(this.message, {Key key}) : super(key: key);

  @override
  _MessageContentState createState() => _MessageContentState();
}

class _MessageContentState extends State<_MessageContent> {
  bool _blockExternalImages;
  bool _messageDownloadError;
  bool _messageRequiresRefresh = false;
  bool _isWebViewZoomedOut = false;
  Object errorObject;
  StackTrace errorStackTrace;

  @override
  void initState() {
    final mime = widget.message.mimeMessage;
    if (mime.isDownloaded) {
      _blockExternalImages = shouldImagesBeBlocked(mime);
    } else {
      _messageRequiresRefresh = widget.message.mimeMessage.envelope == null;
      _blockExternalImages = false;
    }
    _messageDownloadError = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message.mimeMessage;
    final localizations = AppLocalizations.of(context);
    return Base.buildAppChrome(
      context,
      title: msg.decodeSubject() ?? localizations.subjectUndefined,
      content: MessageWidget(
        message: widget.message,
        child: buildMailDetails(localizations),
      ),
      appBarActions: [
        //IconButton(icon: Icon(Icons.reply), onPressed: reply),
        PopupMenuButton<_OverflowMenuChoice>(
          onSelected: (_OverflowMenuChoice result) {
            switch (result) {
              case _OverflowMenuChoice.showContents:
                locator<NavigationService>()
                    .push(Routes.mailContents, arguments: widget.message);
                break;
              case _OverflowMenuChoice.showSourceCode:
                showSourceCode();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<_OverflowMenuChoice>(
              value: _OverflowMenuChoice.showContents,
              child: Text(localizations.viewContentsAction),
            ),
            if (locator<SettingsService>().settings.enableDeveloperMode) ...{
              PopupMenuItem<_OverflowMenuChoice>(
                value: _OverflowMenuChoice.showSourceCode,
                child: Text(localizations.viewSourceAction),
              ),
            },
          ],
        ),
      ],
      bottom: MessageActions(message: widget.message),
    );
  }

  Widget buildMailDetails(AppLocalizations localizations) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildHeader(localizations),
          ),
          buildContent(localizations),
        ],
      ),
    );
  }

  Widget buildHeader(AppLocalizations localizations) {
    final mime = widget.message.mimeMessage;
    final attachments = mime.findContentInfo();
    final inlineAttachments = mime
        .findContentInfo(disposition: ContentDisposition.inline)
        .where((info) => !(info.contentType?.mediaType?.isText ?? false));
    attachments.addAll(inlineAttachments);
    final date = locator<I18nService>().formatDate(mime.decodeDate());
    final subject = mime.decodeSubject();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            columnWidths: {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth()
            },
            children: [
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text(localizations.detailsHeaderFrom),
                ),
                buildMailAddresses(mime.from)
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text(localizations.detailsHeaderTo),
                ),
                buildMailAddresses(mime.to)
              ]),
              if (mime.cc?.isNotEmpty ?? false) ...{
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Text(localizations.detailsHeaderCc),
                  ),
                  buildMailAddresses(mime.cc)
                ]),
              },
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text(localizations.detailsHeaderDate),
                ),
                Text(date),
              ]),
            ]),
        SelectableText(
          subject ?? localizations.subjectUndefined,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        buildAttachments(attachments),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(height: 2),
        ),
        if (_blockExternalImages ||
            mime.isNewsletter ||
            mime.threadSequence != null ||
            _isWebViewZoomedOut) ...{
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (mime.threadSequence != null) ...{
                ThreadSequenceButton(message: widget.message),
              } else ...{
                Container(),
              },
              if (_isWebViewZoomedOut) ...{
                IconButton(
                  icon: Icon(Icons.zoom_in),
                  onPressed: () {
                    locator<NavigationService>()
                        .push(Routes.mailContents, arguments: widget.message);
                  },
                ),
              } else ...{
                Container(),
              },
              if (_blockExternalImages) ...{
                ElevatedButton(
                  child: Text(localizations.detailsActionShowImages),
                  onPressed: () => setState(() {
                    _blockExternalImages = false;
                  }),
                ),
              } else ...{
                Container(),
              },
              if (mime.isNewsletter) ...{
                if (widget.message.isNewsletterUnsubscribed) ...{
                  widget.message.isNewsLetterSubscribable
                      ? ElevatedButton(
                          child: Text(
                              localizations.detailsNewsletterActionResubscribe),
                          onPressed: resubscribe,
                        )
                      : Text(
                          localizations.detailsNewsletterStatusUnsubscribed,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                } else ...{
                  ElevatedButton(
                    child:
                        Text(localizations.detailsNewsletterActionUnsubscribe),
                    onPressed: unsubscribe,
                  ),
                },
              } else ...{
                Container(),
              },
            ],
          ),
        },
      ],
    );
  }

  Widget buildMailAddresses(List<MailAddress> addresses) {
    if (addresses?.isEmpty ?? true) {
      return Container();
    }
    return Wrap(
      //TODO make expansible
      spacing: 2,
      runSpacing: 0,
      children: [
        for (var address in addresses) ...{
          MailAddressChip(mailAddress: address)
        }
      ],
    );
  }

  Widget buildAttachments(List<ContentInfo> attachments) {
    return Wrap(
      children: [
        for (var attachment in attachments) ...{
          AttachmentChip(info: attachment, message: widget.message)
        }
      ],
    );
  }

  Widget buildContent(AppLocalizations localizations) {
    if (_messageDownloadError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(localizations.detailsErrorDownloadInfo),
          ),
          TextButton.icon(
            icon: Icon(Icons.refresh),
            label: Text(localizations.detailsErrorDownloadRetry),
            onPressed: () {
              setState(() {
                _messageDownloadError = false;
              });
            },
          ),
          if (locator<SettingsService>().settings.enableDeveloperMode) ...{
            Text('Details:'),
            Text(errorObject?.toString() ?? '<unknown error>'),
            Text(errorStackTrace?.toString() ?? '<no stacktrace>'),
            TextButton.icon(
              icon: Icon(Icons.copy),
              label: Text('Copy to clipboard'),
              onPressed: () {
                final text = errorObject?.toString() ??
                    '<unknown error>' + '\n\n' + errorStackTrace?.toString() ??
                    '<no stacktrace>';
                final data = ClipboardData(text: text);
                Clipboard.setData(data);
              },
            ),
          },
        ],
      );
    }

    return MimeMessageDownloader(
      mimeMessage: widget.message.mimeMessage,
      mailClient: widget.message.mailClient,
      markAsSeen: true,
      onDownloaded: onMimeMessageDownloaded,
      onError: onMimeMessageError,
      blockExternalImages: _blockExternalImages,
      mailtoDelegate: handleMailto,
      maxImageWidth: 320,
      showMediaDelegate: navigateToMedia,
      includedInlineTypes: [MediaToptype.image],
      onZoomed: (controller, factor) {
        if (factor < 0.9) {
          setState(() {
            _isWebViewZoomedOut = true;
          });
        }
      },
    );
  }

  bool shouldImagesBeBlocked(MimeMessage mimeMessage) {
    var blockExternalImages =
        locator<SettingsService>().settings.blockExternalImages ||
            widget.message.source.shouldBlockImages;
    if (blockExternalImages) {
      final html = mimeMessage.decodeTextHtmlPart();
      final hasImages = (html != null) && (html.contains('<img '));
      if (!hasImages) {
        blockExternalImages = false;
      }
    }
    return blockExternalImages;
  }

  // Update view after message has been downloaded successfully
  void onMimeMessageDownloaded(MimeMessage mimeMessage) {
    widget.message.updateMime(mimeMessage);
    final blockExternalImages = shouldImagesBeBlocked(mimeMessage);
    if (mounted &&
        (_messageRequiresRefresh ||
            mimeMessage.isSeen ||
            mimeMessage.isNewsletter ||
            mimeMessage.hasAttachments() ||
            blockExternalImages)) {
      setState(() {
        _blockExternalImages = blockExternalImages;
      });
    }
    locator<NotificationService>()
        .cancelNotificationForMailMessage(widget.message);
  }

  void onMimeMessageError(Object e, StackTrace s) {
    if (mounted) {
      setState(() {
        errorObject = e;
        errorStackTrace = s;
        _messageDownloadError = true;
      });
    }
  }

  Future handleMailto(Uri mailto, MimeMessage mimeMessage) {
    final messageBuilder = locator<MailService>().mailto(mailto, mimeMessage);
    final composeData =
        ComposeData(widget.message, messageBuilder, ComposeAction.newMessage);
    return locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData);
  }

  Future navigateToMedia(InteractiveMediaWidget mediaWidget) async {
    return locator<NavigationService>()
        .push(Routes.interactiveMedia, arguments: mediaWidget);
  }

  void showSourceCode() {
    locator<NavigationService>()
        .push(Routes.sourceCode, arguments: widget.message.mimeMessage);
  }

  void resubscribe() async {
    final localizations = AppLocalizations.of(context);
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName();
    final confirmation = await DialogHelper.askForConfirmation(context,
        title: localizations.detailsNewsletterResubscribeDialogTitle,
        action: localizations.detailsNewsletterResubscribeDialogAction,
        query:
            localizations.detailsNewsletterResubscribeDialogQuestion(listName));
    if (confirmation == true) {
      // TODO show busy indicator
      final mailClient = widget.message.mailClient;
      final subscribed = await mime.subscribe(mailClient);
      if (subscribed) {
        setState(() {
          widget.message.isNewsletterUnsubscribed = false;
        });
        //TODO store flag only when server/mailbox supports abritrary flags?
        await mailClient.store(MessageSequence.fromMessage(mime),
            [Message.keywordFlagUnsubscribed],
            action: StoreAction.remove);
      }
      await DialogHelper.showTextDialog(
          context,
          subscribed
              ? localizations.detailsNewsletterResubscribeSuccessTitle
              : localizations.detailsNewsletterResubscribeFailureTitle,
          subscribed
              ? localizations
                  .detailsNewsletterResubscribeSuccessMessage(listName)
              : localizations
                  .detailsNewsletterResubscribeFailureMessage(listName));
    }
  }

  void unsubscribe() async {
    final localizations = AppLocalizations.of(context);
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName();
    final confirmation = await DialogHelper.askForConfirmation(
      context,
      title: localizations.detailsNewsletterUnsubscribeDialogTitle,
      action: localizations.detailsNewsletterUnsubscribeDialogAction,
      query: localizations.detailsNewsletterUnsubscribeDialogQuestion(listName),
    );
    if (confirmation == true) {
      // TODO show busy indicator
      final mailClient = widget.message.mailClient;
      var unsubscribed = false;
      try {
        unsubscribed = await mime.unsubscribe(mailClient);
      } catch (e, s) {
        print('error during unsubscribe: $e $s');
      }
      if (unsubscribed) {
        setState(() {
          widget.message.isNewsletterUnsubscribed = true;
        });
        //TODO store flag only when server/mailbox supports abritrary flags?
        try {
          await mailClient.store(MessageSequence.fromMessage(mime),
              [Message.keywordFlagUnsubscribed],
              action: StoreAction.add);
        } catch (e, s) {
          print('error during unsubscribe flag store operation: $e $s');
        }
      }
      await DialogHelper.showTextDialog(
          context,
          unsubscribed
              ? localizations.detailsNewsletterUnsubscribeSuccessTitle
              : localizations.detailsNewsletterUnsubscribeFailureTitle,
          unsubscribed
              ? localizations
                  .detailsNewsletterUnsubscribeSuccessMessage(listName)
              : localizations
                  .detailsNewsletterUnsubscribeFailureMessage(listName));
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
}

class MessageContentsScreen extends StatelessWidget {
  final Message message;
  const MessageContentsScreen({Key key, @required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: message.mimeMessage.decodeSubject() ??
          AppLocalizations.of(context).subjectUndefined,
      content: MimeMessageViewer(
        mimeMessage: message.mimeMessage,
        adjustHeight: false,
        mailtoDelegate: handleMailto,
        showMediaDelegate: navigateToMedia,
      ),
    );
  }

  Future handleMailto(Uri mailto, MimeMessage mimeMessage) {
    final messageBuilder = locator<MailService>().mailto(mailto, mimeMessage);
    final composeData =
        ComposeData(message, messageBuilder, ComposeAction.newMessage);
    return locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData);
  }

  Future navigateToMedia(InteractiveMediaWidget mediaWidget) {
    return locator<NavigationService>()
        .push(Routes.interactiveMedia, arguments: mediaWidget);
  }
}

class ThreadSequenceButton extends StatefulWidget {
  final Message message;
  ThreadSequenceButton({Key key, @required this.message}) : super(key: key);

  @override
  _ThreadSequenceButtonState createState() => _ThreadSequenceButtonState();
}

class _ThreadSequenceButtonState extends State<ThreadSequenceButton> {
  OverlayEntry _overlayEntry;
  Future<List<Message>> _loadingFuture;

  @override
  void dispose() {
    if (_overlayEntry != null) {
      removeOverlay();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadingFuture = loadMessages();
  }

  Future<List<Message>> loadMessages() async {
    final existingSource = widget.message.source;
    if (existingSource is ListMessageSource) {
      return existingSource.messages;
    }
    final mailClient = widget.message.mailClient;
    final mimeMessages = await mailClient.fetchMessageSequence(
        widget.message.mimeMessage.threadSequence,
        fetchPreference: FetchPreference.envelope);
    final source = ListMessageSource(widget.message.source);
    final messages = <Message>[];
    for (var i = 0; i < mimeMessages.length; i++) {
      final mime = mimeMessages[i];
      final message = Message(mime, mailClient, source, i);
      messages.add(message);
    }
    source.messages = messages;
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.message.mimeMessage.threadSequence?.length ?? 0;
    return WillPopScope(
      onWillPop: () {
        if (_overlayEntry == null) {
          return Future.value(true);
        }
        removeOverlay();
        return Future.value(false);
      },
      child: IconButton(
        icon: IconService.buildNumericIcon(length),
        onPressed: () {
          _overlayEntry = _buildThreadsOverlay();
          Overlay.of(context).insert(_overlayEntry);
        },
      ),
    );
  }

  void removeOverlay() {
    _overlayEntry.remove();
    _overlayEntry = null;
  }

  void select(Message message) {
    removeOverlay();
    locator<NavigationService>()
        .push(Routes.mailDetails, arguments: message, replace: false);
  }

  OverlayEntry _buildThreadsOverlay() {
    RenderBox renderBox = context.findRenderObject();
    final offset = renderBox.localToGlobal(Offset.zero);
    final renderSize = renderBox.size;
    final size = MediaQuery.of(context).size;
    final currentUid = widget.message.mimeMessage.uid;
    final top = offset.dy + renderSize.height + 5.0;
    final height = size.height - top - 16;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          removeOverlay();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: offset.dx,
              top: top,
              width: size.width - offset.dx - 16,
              child: Material(
                elevation: 4.0,
                child: FutureBuilder<List<Message>>(
                  future: _loadingFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final messages = snapshot.data;
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: height),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: messages
                            .map((message) => ListTile(
                                  title:
                                      MessageOverviewContent(message: message),
                                  onTap: () => select(message),
                                  selected:
                                      (message.mimeMessage.uid == currentUid),
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
