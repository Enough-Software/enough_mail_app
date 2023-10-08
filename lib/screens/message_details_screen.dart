import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../locator.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../models/message_source.dart';
import '../routes.dart';
import '../services/i18n_service.dart';
import '../services/icon_service.dart';
import '../services/mail_service.dart';
import '../services/navigation_service.dart';
import '../services/notification_service.dart';
import '../settings/model.dart';
import '../settings/provider.dart';
import '../util/localized_dialog_helper.dart';
import '../widgets/attachment_chip.dart';
import '../widgets/button_text.dart';
import '../widgets/empty_message.dart';
import '../widgets/expansion_wrap.dart';
import '../widgets/ical_interactive_media.dart';
import '../widgets/mail_address_chip.dart';
import '../widgets/message_actions.dart';
import '../widgets/message_overview_content.dart';
import 'base.dart';

class MessageDetailsScreen extends ConsumerStatefulWidget {
  const MessageDetailsScreen({
    super.key,
    required this.message,
    this.blockExternalContents = false,
  });
  final Message message;
  final bool blockExternalContents;

  @override
  ConsumerState<MessageDetailsScreen> createState() => _DetailsScreenState();
}

enum _OverflowMenuChoice { showContents, showSourceCode }

class _DetailsScreenState extends ConsumerState<MessageDetailsScreen> {
  late PageController _pageController;
  late MessageSource _source;
  late Message _current;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.message.sourceIndex);
    _current = widget.message;
    _current.addListener(_update);
    _source = _current.source;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _current.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  Future<Message> _getMessageAt(int index) {
    if (_current.sourceIndex == index) {
      return Future.value(_current);
    }
    return _source.getMessageAt(index);
  }

  bool _blockExternalContents(int index) {
    if (_current.sourceIndex == index) {
      return widget.blockExternalContents;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;
    return BasePage(
      title: _current.mimeMessage.decodeSubject() ??
          localizations.subjectUndefined,
      appBarActions: [
        //PlatformIconButton(icon: Icon(Icons.reply), onPressed: reply),
        PlatformPopupMenuButton<_OverflowMenuChoice>(
          onSelected: (_OverflowMenuChoice result) {
            switch (result) {
              case _OverflowMenuChoice.showContents:
                locator<NavigationService>()
                    .push(Routes.mailContents, arguments: _current);
                break;
              case _OverflowMenuChoice.showSourceCode:
                _showSourceCode();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PlatformPopupMenuItem<_OverflowMenuChoice>(
              value: _OverflowMenuChoice.showContents,
              child: Text(localizations.viewContentsAction),
            ),
            if (ref.read(settingsProvider).enableDeveloperMode)
              PlatformPopupMenuItem<_OverflowMenuChoice>(
                value: _OverflowMenuChoice.showSourceCode,
                child: Text(localizations.viewSourceAction),
              ),
          ],
        ),
      ],
      bottom: MessageActions(message: _current),
      content: PageView.builder(
        controller: _pageController,
        itemCount: _source.size,
        itemBuilder: (context, index) => FutureBuilder<Message>(
          future: _getMessageAt(index),
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return const EmptyMessage();
            }
            return _MessageContent(
              data,
              blockExternalContents: _blockExternalContents(index),
            );
          },
        ),
        onPageChanged: (index) async {
          final current = await _getMessageAt(index);
          setState(() {
            _current.removeListener(_update);
            _current = current;
            _current.addListener(_update);
          });
        },
      ),
    );
  }

  void _showSourceCode() {
    locator<NavigationService>()
        .push(Routes.sourceCode, arguments: _current.mimeMessage);
  }
}

class _MessageContent extends ConsumerStatefulWidget {
  const _MessageContent(this.message, {this.blockExternalContents = false});
  final Message message;
  final bool blockExternalContents;

  @override
  ConsumerState<_MessageContent> createState() => _MessageContentState();
}

class _MessageContentState extends ConsumerState<_MessageContent> {
  late bool _blockExternalImages;
  bool _messageDownloadError = false;
  bool _messageRequiresRefresh = false;
  bool _isWebViewZoomedOut = false;
  Object? errorObject;
  StackTrace? errorStackTrace;
  bool _notifyMarkedAsSeen = false;

  @override
  void initState() {
    final message = widget.message;
    final mime = message.mimeMessage;
    if (widget.blockExternalContents) {
      _blockExternalImages = true;
    } else if (mime.isDownloaded) {
      _blockExternalImages = _shouldImagesBeBlocked(mime);
      if (!mime.isSeen) {
        unawaited(message.source.markAsSeen(message, true));
      }
    } else {
      _messageRequiresRefresh = mime.envelope == null;
      _blockExternalImages = false;
    }
    _notifyMarkedAsSeen = !mime.isSeen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;

    return _buildMailDetails(localizations);
  }

  Widget _buildMailDetails(AppLocalizations localizations) =>
      SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildHeader(localizations),
              ),
              _buildContent(localizations),
            ],
          ),
        ),
      );

  Widget _buildHeader(AppLocalizations localizations) {
    final mime = widget.message.mimeMessage;
    final attachments = widget.message.attachments;
    final date = locator<I18nService>().formatDateTime(mime.decodeDate());
    final subject = mime.decodeSubject();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text(localizations.detailsHeaderFrom),
                ),
                _buildMailAddresses(mime.from)
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text(localizations.detailsHeaderTo),
                ),
                _buildMailAddresses(mime.to)
              ],
            ),
            if (mime.cc?.isNotEmpty ?? false)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Text(localizations.detailsHeaderCc),
                  ),
                  _buildMailAddresses(mime.cc)
                ],
              ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text(localizations.detailsHeaderDate),
                ),
                Text(date),
              ],
            ),
          ],
        ),
        SelectableText(
          subject ?? localizations.subjectUndefined,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildAttachments(attachments),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Divider(height: 2),
        ),
        if (_blockExternalImages ||
            mime.isNewsletter ||
            mime.threadSequence != null ||
            _isWebViewZoomedOut)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (mime.threadSequence != null)
                ThreadSequenceButton(message: widget.message)
              else
                Container(),
              if (_isWebViewZoomedOut)
                PlatformIconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () {
                    locator<NavigationService>()
                        .push(Routes.mailContents, arguments: widget.message);
                  },
                )
              else
                Container(),
              if (_blockExternalImages)
                PlatformElevatedButton(
                  child: ButtonText(localizations.detailsActionShowImages),
                  onPressed: () => setState(
                    () {
                      _blockExternalImages = false;
                    },
                  ),
                )
              else
                Container(),
              if (mime.isNewsletter)
                UnsubscribeButton(
                  message: widget.message,
                )
              else
                Container(),
            ],
          ),
        if (ReadReceiptButton.shouldBeShown(mime, ref.read(settingsProvider)))
          ReadReceiptButton(
            message: widget.message,
          ),
      ],
    );
  }

  Widget _buildMailAddresses(List<MailAddress>? addresses) {
    if (addresses?.isEmpty ?? true) {
      return Container();
    }
    return MailAddressList(mailAddresses: addresses!);
  }

  Widget _buildAttachments(List<ContentInfo> attachments) => Wrap(
        children: [
          for (final attachment in attachments)
            AttachmentChip(info: attachment, message: widget.message),
        ],
      );

  Widget _buildContent(AppLocalizations localizations) {
    if (_messageDownloadError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(localizations.detailsErrorDownloadInfo),
          ),
          TextButton.icon(
            icon: Icon(CommonPlatformIcons.refresh),
            label: ButtonText(localizations.detailsErrorDownloadRetry),
            onPressed: () {
              setState(() {
                _messageDownloadError = false;
              });
            },
          ),
          if (ref.read(settingsProvider).enableDeveloperMode) ...[
            const Text('Details:'),
            SelectableText(errorObject?.toString() ?? '<unknown error>'),
            SelectableText(errorStackTrace?.toString() ?? '<no stacktrace>'),
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: const ButtonText('Copy to clipboard'),
              onPressed: () {
                final text =
                    '${errorObject?.toString() ?? '<unknown error>'} \n'
                    '${errorStackTrace?.toString() ?? '<no stacktrace>'}';
                final data = ClipboardData(text: text);
                Clipboard.setData(data);
              },
            ),
          ],
        ],
      );
    }
    final message = widget.message;

    return MimeMessageDownloader(
      mimeMessage: message.mimeMessage,
      mailClient: message.mailClient,
      fetchMessageContents: (
        mimeMessage, {
        int? maxSize,
        bool markAsSeen = false,
        List<MediaToptype>? includedInlineTypes,
        Duration? responseTimeout,
      }) =>
          message.source.fetchMessageContents(
        message,
        maxSize: maxSize,
        markAsSeen: markAsSeen,
        includedInlineTypes: includedInlineTypes,
        responseTimeout: responseTimeout,
      ),
      markAsSeen: true,
      onDownloaded: _onMimeMessageDownloaded,
      onError: _onMimeMessageError,
      blockExternalImages: _blockExternalImages,
      preferPlainText: ref.read(settingsProvider).preferPlainTextMessages,
      enableDarkMode: Theme.of(context).brightness == Brightness.dark,
      mailtoDelegate: _handleMailto,
      maxImageWidth: 320,
      showMediaDelegate: _navigateToMedia,
      includedInlineTypes: const [MediaToptype.image],
      urlLauncherDelegate: (url) {
        // skip canLaunch check due to bug when handling URLs registered by apps
        // https://github.com/flutter/flutter/issues/93765
        final uri = Uri.parse(
          url.startsWith('http://')
              ? 'https://${url.substring('http://'.length)}'
              : url,
        );

        launcher.launchUrl(
          uri,
          mode: ref.read(settingsProvider).urlLaunchMode,
        );
        return Future.value(true);
      },
      onZoomed: (controller, factor) {
        if (factor < 0.9) {
          setState(() {
            _isWebViewZoomedOut = true;
          });
        }
      },
      builder: (context, mimeMessage) {
        final textCalendarPart =
            mimeMessage.getAlternativePart(MediaSubtype.textCalendar);
        if (textCalendarPart != null) {
          // || mediaType.sub == MediaSubtype.applicationIcs)
          final calendarText = textCalendarPart.decodeContentText();
          if (calendarText != null) {
            final mediaProvider =
                TextMediaProvider('invite.ics', 'text/calendar', calendarText);
            return IcalInteractiveMedia(
                mediaProvider: mediaProvider, message: widget.message);
          }
        }
        return null;
      },
    );
  }

  bool _shouldImagesBeBlocked(MimeMessage mimeMessage) {
    var blockExternalImages = widget.blockExternalContents ||
        ref.read(settingsProvider).blockExternalImages ||
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
  void _onMimeMessageDownloaded(MimeMessage mimeMessage) {
    widget.message.updateMime(mimeMessage);
    final blockExternalImages = _shouldImagesBeBlocked(mimeMessage);
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
    if (_notifyMarkedAsSeen) {
      widget.message.source.onMarkedAsSeen(widget.message, true);
    }
  }

  void _onMimeMessageError(Object? e, StackTrace? s) {
    if (mounted) {
      setState(() {
        errorObject = e;
        errorStackTrace = s;
        _messageDownloadError = true;
      });
    }
  }

  Future _handleMailto(Uri mailto, MimeMessage mimeMessage) {
    final settings = ref.read(settingsProvider);
    final messageBuilder = locator<MailService>().mailto(
      mailto,
      mimeMessage,
      settings,
    );
    final composeData =
        ComposeData([widget.message], messageBuilder, ComposeAction.newMessage);

    return locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData);
  }

  Future _navigateToMedia(InteractiveMediaWidget mediaWidget) async =>
      locator<NavigationService>()
          .push(Routes.interactiveMedia, arguments: mediaWidget);

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
}

class MessageContentsScreen extends ConsumerWidget {
  const MessageContentsScreen({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Base.buildAppChrome(
        context,
        title: message.mimeMessage.decodeSubject() ??
            context.text.subjectUndefined,
        content: SafeArea(
          child: MimeMessageViewer(
            mimeMessage: message.mimeMessage,
            adjustHeight: false,
            mailtoDelegate: (uri, mime) =>
                _handleMailto(uri, mime, ref.read(settingsProvider)),
            showMediaDelegate: _navigateToMedia,
            enableDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );

  Future _handleMailto(
    Uri mailto,
    MimeMessage mimeMessage,
    Settings settings,
  ) {
    final messageBuilder = locator<MailService>().mailto(
      mailto,
      mimeMessage,
      settings,
    );
    final composeData =
        ComposeData([message], messageBuilder, ComposeAction.newMessage);

    return locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData);
  }

  Future _navigateToMedia(InteractiveMediaWidget mediaWidget) =>
      locator<NavigationService>()
          .push(Routes.interactiveMedia, arguments: mediaWidget);
}

class ThreadSequenceButton extends StatefulWidget {
  const ThreadSequenceButton({super.key, required this.message});
  final Message message;

  @override
  State<ThreadSequenceButton> createState() => _ThreadSequenceButtonState();
}

class _ThreadSequenceButtonState extends State<ThreadSequenceButton> {
  OverlayEntry? _overlayEntry;
  late Future<List<Message>> _loadingFuture;

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _removeOverlay();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadMessages();
  }

  Future<List<Message>> _loadMessages() async {
    final existingSource = widget.message.source;
    if (existingSource is ListMessageSource) {
      return existingSource.messages;
    }
    final mailClient = widget.message.mailClient;
    final mimeMessages = await mailClient.fetchMessageSequence(
        widget.message.mimeMessage.threadSequence!,
        fetchPreference: FetchPreference.envelope);
    final source = ListMessageSource(widget.message.source)
      ..initWithMimeMessages(mimeMessages, mailClient);
    return source.messages;
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.message.mimeMessage.threadSequence?.length ?? 0;
    return WillPopScope(
      onWillPop: () {
        if (_overlayEntry == null) {
          return Future.value(true);
        }
        _removeOverlay();
        return Future.value(false);
      },
      child: PlatformIconButton(
        icon: IconService.buildNumericIcon(context, length),
        onPressed: () {
          if (_overlayEntry != null) {
            _removeOverlay();
          } else {
            _overlayEntry = _buildThreadsOverlay();
            Overlay.of(context).insert(_overlayEntry!);
          }
        },
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry!.remove();
    _overlayEntry = null;
  }

  void _select(Message message) {
    _removeOverlay();
    locator<NavigationService>().push(Routes.mailDetails, arguments: message);
  }

  OverlayEntry _buildThreadsOverlay() {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final renderSize = renderBox.size;
    final size = MediaQuery.of(context).size;
    final currentUid = widget.message.mimeMessage.uid;
    final top = offset.dy + renderSize.height + 5.0;
    final height = size.height - top - 16;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0x09000000))),
            Positioned(
              left: offset.dx,
              top: top,
              width: size.width - offset.dx - 16,
              child: Material(
                elevation: 4,
                child: FutureBuilder<List<Message>?>(
                  future: _loadingFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: PlatformProgressIndicator(),
                      );
                    }
                    final messages = snapshot.data!;
                    final isSentFolder = widget.message.source.isSent;
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: height),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: messages
                            .map((message) => SelectablePlatformListTile(
                                  title: MessageOverviewContent(
                                    message: message,
                                    isSentMessage: isSentFolder,
                                  ),
                                  onTap: () => _select(message),
                                  selected:
                                      message.mimeMessage.uid == currentUid,
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

class ReadReceiptButton extends StatefulWidget {
  const ReadReceiptButton({super.key, required this.message});
  final Message message;

  @override
  State<ReadReceiptButton> createState() => _ReadReceiptButtonState();

  static bool shouldBeShown(MimeMessage mime, Settings settings) =>
      (mime.isReadReceiptSent || mime.isReadReceiptRequested) &&
      (settings.readReceiptDisplaySetting != ReadReceiptDisplaySetting.never);
}

class _ReadReceiptButtonState extends State<ReadReceiptButton> {
  bool _isSendingReadReceipt = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final mime = message.mimeMessage;
    final localizations = context.text;
    if (mime.isReadReceiptSent) {
      return Text(
        localizations.detailsReadReceiptSentStatus,
        style: Theme.of(context).textTheme.bodySmall,
      );
    } else if (_isSendingReadReceipt) {
      return const PlatformProgressIndicator();
    } else {
      return ElevatedButton(
        child: ButtonText(localizations.detailsSendReadReceiptAction),
        onPressed: () async {
          setState(() {
            _isSendingReadReceipt = true;
          });
          final readReceipt = MessageBuilder.buildReadReceipt(
            mime,
            message.account.fromAddress,
            reportingUa: 'Maily 1.0',
            subject: localizations.detailsReadReceiptSubject,
          );
          await message.mailClient
              .sendMessage(readReceipt, appendToSent: false);
          await message.mailClient.flagMessage(mime, isReadReceiptSent: true);
          setState(() {
            _isSendingReadReceipt = false;
          });
        },
      );
    }
  }
}

class UnsubscribeButton extends StatefulWidget {
  const UnsubscribeButton({super.key, required this.message});
  final Message message;

  @override
  State<UnsubscribeButton> createState() => _UnsubscribeButtonState();
}

class _UnsubscribeButtonState extends State<UnsubscribeButton> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    if (_isActive) {
      return const PlatformProgressIndicator();
    }
    final localizations = context.text;
    if (widget.message.isNewsletterUnsubscribed) {
      return widget.message.isNewsLetterSubscribable
          ? PlatformElevatedButton(
              onPressed: _resubscribe,
              child:
                  ButtonText(localizations.detailsNewsletterActionResubscribe),
            )
          : Text(
              localizations.detailsNewsletterStatusUnsubscribed,
              style: const TextStyle(fontStyle: FontStyle.italic),
            );
    } else {
      return PlatformElevatedButton(
        onPressed: _unsubscribe,
        child: ButtonText(localizations.detailsNewsletterActionUnsubscribe),
      );
    }
  }

  Future<void> _resubscribe() async {
    final localizations = context.text;
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName()!;
    final confirmation = await LocalizedDialogHelper.askForConfirmation(context,
        title: localizations.detailsNewsletterResubscribeDialogTitle,
        action: localizations.detailsNewsletterResubscribeDialogAction,
        query:
            localizations.detailsNewsletterResubscribeDialogQuestion(listName));
    if (confirmation == true) {
      setState(() {
        _isActive = true;
      });
      final mailClient = widget.message.mailClient;
      final subscribed = await mime.subscribe(mailClient);
      setState(() {
        _isActive = false;
      });
      if (subscribed) {
        setState(() {
          widget.message.isNewsletterUnsubscribed = false;
        });
        //TODO store flag only when server/mailbox supports arbitrary flags?
        await mailClient.store(MessageSequence.fromMessage(mime),
            [Message.keywordFlagUnsubscribed],
            action: StoreAction.remove);
      }
      await LocalizedDialogHelper.showTextDialog(
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

  Future<void> _unsubscribe() async {
    final localizations = context.text;
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName()!;
    final confirmation = await LocalizedDialogHelper.askForConfirmation(
      context,
      title: localizations.detailsNewsletterUnsubscribeDialogTitle,
      action: localizations.detailsNewsletterUnsubscribeDialogAction,
      query: localizations.detailsNewsletterUnsubscribeDialogQuestion(listName),
    );
    if (confirmation == true) {
      setState(() {
        _isActive = true;
      });
      final mailClient = widget.message.mailClient;
      var unsubscribed = false;
      try {
        unsubscribed = await mime.unsubscribe(mailClient);
      } catch (e, s) {
        if (kDebugMode) {
          print('error during unsubscribe: $e $s');
        }
      }
      setState(() {
        _isActive = false;
      });
      if (unsubscribed) {
        setState(() {
          widget.message.isNewsletterUnsubscribed = true;
        });
        //TODO store flag only when server/mailbox supports arbitrary flags?
        try {
          await mailClient.store(MessageSequence.fromMessage(mime),
              [Message.keywordFlagUnsubscribed]);
        } catch (e, s) {
          if (kDebugMode) {
            print('error during unsubscribe flag store operation: $e $s');
          }
        }
      }
      await LocalizedDialogHelper.showTextDialog(
        context,
        unsubscribed
            ? localizations.detailsNewsletterUnsubscribeSuccessTitle
            : localizations.detailsNewsletterUnsubscribeFailureTitle,
        unsubscribed
            ? localizations.detailsNewsletterUnsubscribeSuccessMessage(listName)
            : localizations
                .detailsNewsletterUnsubscribeFailureMessage(listName),
      );
    }
  }
}

class MailAddressList extends StatefulWidget {
  const MailAddressList({super.key, required this.mailAddresses});
  final List<MailAddress> mailAddresses;

  @override
  State<MailAddressList> createState() => _MailAddressListState();
}

class _MailAddressListState extends State<MailAddressList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) => ExpansionWrap(
        spacing: 4,
        expandIndicator: DensePlatformIconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            setState(() {
              _isExpanded = true;
            });
          },
        ),
        compressIndicator: DensePlatformIconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            setState(() {
              _isExpanded = false;
            });
          },
        ),
        isExpanded: _isExpanded,
        maxRuns: 2,
        children: [
          for (final address in widget.mailAddresses)
            MailAddressChip(mailAddress: address),
        ],
      );
}
