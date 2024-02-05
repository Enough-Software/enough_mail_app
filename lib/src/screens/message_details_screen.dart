import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../logger.dart';
import '../mail/provider.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../models/message_source.dart';
import '../notification/service.dart';
import '../routes/routes.dart';
import '../settings/model.dart';
import '../settings/provider.dart';
import '../settings/theme/icon_service.dart';
import '../util/localized_dialog_helper.dart';
import '../widgets/attachment_chip.dart';
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
    this.blockExternalContent = false,
  });
  final Message message;
  final bool blockExternalContent;

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
    _source = _current.source;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Message> _getMessageAt(int index) {
    if (_current.sourceIndex == index) {
      return Future.value(_current);
    }

    return _source.getMessageAt(index);
  }

  bool _blockExternalContents(int index) =>
      _current.sourceIndex == index && widget.blockExternalContent;

  @override
  Widget build(BuildContext context) {
    final localizations = ref.text;

    return ListenableBuilder(
      listenable: _current,
      builder: (context, child) => BasePage(
        title: _current.mimeMessage.decodeSubject() ??
            localizations.subjectUndefined,
        appBarActions: [
          //PlatformIconButton(icon: Icon(Icons.reply), onPressed: reply),
          PlatformPopupMenuButton<_OverflowMenuChoice>(
            onSelected: (_OverflowMenuChoice result) {
              switch (result) {
                case _OverflowMenuChoice.showContents:
                  context.pushNamed(Routes.mailContents, extra: _current);
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
              _current = current;
            });
          },
        ),
      ),
    );
  }

  void _showSourceCode() =>
      context.pushNamed(Routes.sourceCode, extra: _current.mimeMessage);
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
  late bool _settingsBlockExternalImages;

  @override
  void initState() {
    final message = widget.message;
    final mime = message.mimeMessage;
    _settingsBlockExternalImages =
        ref.read(settingsProvider).blockExternalImages;
    if (widget.blockExternalContents) {
      _blockExternalImages = true;
    } else if (mime.isDownloaded) {
      _blockExternalImages = _shouldImagesBeBlocked(mime);
      if (!mime.isSeen) {
        Future.delayed(const Duration(milliseconds: 50)).then(
          (_) => message.source.markAsSeen(message, true),
        );
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
    final localizations = ref.text;

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildHeader(context, localizations),
            ),
            _buildContent(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    final mime = widget.message.mimeMessage;
    final attachments = widget.message.attachments;
    final date = ref.formatDateTime(mime.decodeDate());
    final subject = mime.decodeSubject();

    TableRow rowWithLabel({required String label, required Widget child}) =>
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Text(label),
            ),
            child,
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          children: [
            rowWithLabel(
              label: localizations.detailsHeaderFrom,
              child: _buildMailAddresses(mime.from),
            ),
            rowWithLabel(
              label: localizations.detailsHeaderTo,
              child: _buildMailAddresses(mime.to),
            ),
            if (mime.cc?.isNotEmpty ?? false)
              rowWithLabel(
                label: localizations.detailsHeaderCc,
                child: _buildMailAddresses(mime.cc),
              ),
            rowWithLabel(
              label: localizations.detailsHeaderDate,
              child: Text(date),
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
                const SizedBox.shrink(),
              if (_isWebViewZoomedOut)
                PlatformIconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () => context.pushNamed(
                    Routes.mailContents,
                    extra: widget.message,
                  ),
                )
              else
                const SizedBox.shrink(),
              if (_blockExternalImages)
                PlatformElevatedButton(
                  child: Text(localizations.detailsActionShowImages),
                  onPressed: () => setState(
                    () {
                      _blockExternalImages = false;
                    },
                  ),
                )
              else
                const SizedBox.shrink(),
              if (mime.isNewsletter)
                UnsubscribeButton(
                  message: widget.message,
                )
              else
                const SizedBox.shrink(),
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
    if (addresses == null || addresses.isEmpty) {
      return const SizedBox.shrink();
    }

    return MailAddressList(mailAddresses: addresses);
  }

  Widget _buildAttachments(List<ContentInfo> attachments) => Wrap(
        children: [
          for (final attachment in attachments)
            AttachmentChip(info: attachment, message: widget.message),
        ],
      );

  Widget _buildMessageDownloadErrorContent(AppLocalizations localizations) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(localizations.detailsErrorDownloadInfo),
          ),
          TextButton.icon(
            icon: Icon(CommonPlatformIcons.refresh),
            label: Text(localizations.detailsErrorDownloadRetry),
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
              label: const Text('Copy to clipboard'),
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

  Widget _buildContent(AppLocalizations localizations) {
    if (_messageDownloadError) {
      return _buildMessageDownloadErrorContent(localizations);
    }
    final message = widget.message;

    return MimeMessageDownloader(
      mimeMessage: message.mimeMessage,
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
      logger: logger,
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
              mediaProvider: mediaProvider,
              message: widget.message,
            );
          }
        }

        return null;
      },
    );
  }

  bool _shouldImagesBeBlocked(MimeMessage mimeMessage) {
    var blockExternalImages = widget.blockExternalContents ||
        _settingsBlockExternalImages ||
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
    NotificationService.instance.cancelNotificationForMessage(widget.message);
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
    final messageBuilder = ref.read(
      mailtoProvider(
        mailtoUri: mailto,
        originatingMessage: mimeMessage,
      ),
    );
    final composeData =
        ComposeData([widget.message], messageBuilder, ComposeAction.newMessage);

    return context.pushNamed(Routes.mailCompose, extra: composeData);
  }

  Future _navigateToMedia(InteractiveMediaWidget mediaWidget) =>
      context.pushNamed(Routes.interactiveMedia, extra: mediaWidget);

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
  Widget build(BuildContext context, WidgetRef ref) => BasePage(
        title: message.mimeMessage.decodeSubject() ?? ref.text.subjectUndefined,
        content: SafeArea(
          child: MimeMessageViewer(
            mimeMessage: message.mimeMessage,
            adjustHeight: false,
            mailtoDelegate: (uri, mime) =>
                _handleMailto(context, ref, uri, mime),
            showMediaDelegate: (mediaViewer) =>
                _navigateToMedia(context, mediaViewer),
            enableDarkMode: Theme.of(context).brightness == Brightness.dark,
            logger: logger,
          ),
        ),
      );

  Future _handleMailto(
    BuildContext context,
    WidgetRef ref,
    Uri mailto,
    MimeMessage mimeMessage,
  ) {
    final messageBuilder = ref.read(
      mailtoProvider(
        mailtoUri: mailto,
        originatingMessage: mimeMessage,
      ),
    );
    final composeData =
        ComposeData([message], messageBuilder, ComposeAction.newMessage);

    return context.pushNamed(Routes.mailCompose, extra: composeData);
  }

  Future _navigateToMedia(
    BuildContext context,
    InteractiveMediaWidget mediaWidget,
  ) =>
      context.pushNamed(Routes.interactiveMedia, extra: mediaWidget);
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
    final threadSequence = widget.message.mimeMessage.threadSequence;
    if (threadSequence == null || threadSequence.isEmpty) {
      return [];
    }
    final mailClient =
        widget.message.source.getMimeSource(widget.message)?.mailClient;
    if (mailClient == null) {
      return [];
    }

    final mimeMessages = await mailClient.fetchMessageSequence(
      threadSequence,
      fetchPreference: FetchPreference.envelope,
    );
    final source = ListMessageSource(widget.message.source)
      ..initWithMimeMessages(mimeMessages);

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
            final overlayEntry = _buildThreadsOverlay();
            _overlayEntry = overlayEntry;
            Overlay.of(context).insert(overlayEntry);
          }
        },
      ),
    );
  }

  void _removeOverlay() {
    final overlayEntry = _overlayEntry;
    if (overlayEntry != null) {
      overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  void _select(Message message) {
    _removeOverlay();
    context.pushNamed(Routes.mailDetails, extra: message);
  }

  OverlayEntry _buildThreadsOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final renderSize = renderBox?.size ?? const Size(120, 400);
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
                    final data = snapshot.data;
                    if (data == null) {
                      return const Center(
                        child: PlatformProgressIndicator(),
                      );
                    }
                    final messages = data;
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

class ReadReceiptButton extends StatefulHookConsumerWidget {
  const ReadReceiptButton({super.key, required this.message});
  final Message message;

  @override
  ConsumerState<ReadReceiptButton> createState() => _ReadReceiptButtonState();

  static bool shouldBeShown(MimeMessage mime, Settings settings) =>
      (mime.isReadReceiptSent || mime.isReadReceiptRequested) &&
      (settings.readReceiptDisplaySetting != ReadReceiptDisplaySetting.never);
}

class _ReadReceiptButtonState extends ConsumerState<ReadReceiptButton> {
  bool _isSendingReadReceipt = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final mime = message.mimeMessage;
    final localizations = ref.text;
    if (mime.isReadReceiptSent) {
      return Text(
        localizations.detailsReadReceiptSentStatus,
        style: Theme.of(context).textTheme.bodySmall,
      );
    } else if (_isSendingReadReceipt) {
      return const PlatformProgressIndicator();
    } else {
      return ElevatedButton(
        child: Text(localizations.detailsSendReadReceiptAction),
        onPressed: () async {
          setState(() {
            _isSendingReadReceipt = true;
          });
          final mailClient = message.source.getMimeSource(message)?.mailClient;
          if (mailClient == null) {
            return;
          }
          final readReceipt = MessageBuilder.buildReadReceipt(
            mime,
            message.account.fromAddress,
            reportingUa: 'Maily 1.0',
            subject: localizations.detailsReadReceiptSubject,
          );

          await mailClient.sendMessage(readReceipt, appendToSent: false);
          await mailClient.flagMessage(mime, isReadReceiptSent: true);
          setState(() {
            _isSendingReadReceipt = false;
          });
        },
      );
    }
  }
}

class UnsubscribeButton extends StatefulHookConsumerWidget {
  const UnsubscribeButton({super.key, required this.message});
  final Message message;

  @override
  ConsumerState<UnsubscribeButton> createState() => _UnsubscribeButtonState();
}

class _UnsubscribeButtonState extends ConsumerState<UnsubscribeButton> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    if (_isActive) {
      return const PlatformProgressIndicator();
    }
    final localizations = ref.text;

    return widget.message.isNewsletterUnsubscribed
        ? widget.message.isNewsLetterSubscribable
            ? PlatformElevatedButton(
                onPressed: _resubscribe,
                child: Text(localizations.detailsNewsletterActionResubscribe),
              )
            : Text(
                localizations.detailsNewsletterStatusUnsubscribed,
                style: const TextStyle(fontStyle: FontStyle.italic),
              )
        : PlatformElevatedButton(
            onPressed: _unsubscribe,
            child: Text(localizations.detailsNewsletterActionUnsubscribe),
          );
  }

  Future<void> _resubscribe() async {
    final localizations = ref.text;
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName() ?? '<>';
    final confirmation = await LocalizedDialogHelper.askForConfirmation(
      ref,
      title: localizations.detailsNewsletterResubscribeDialogTitle,
      action: localizations.detailsNewsletterResubscribeDialogAction,
      query: localizations.detailsNewsletterResubscribeDialogQuestion(listName),
    );
    if (confirmation ?? false) {
      setState(() {
        _isActive = true;
      });
      final mailClient =
          widget.message.source.getMimeSource(widget.message)?.mailClient;
      final subscribed = mailClient != null && await mime.subscribe(mailClient);
      setState(() {
        _isActive = false;
      });
      if (subscribed) {
        setState(() {
          widget.message.isNewsletterUnsubscribed = false;
        });
        // TODO(RV): store flag only when server/mailbox supports arbitrary flags?
        await mailClient.store(
          MessageSequence.fromMessage(mime),
          [Message.keywordFlagUnsubscribed],
          action: StoreAction.remove,
        );
      }
      if (context.mounted) {
        await LocalizedDialogHelper.showTextDialog(
          ref,
          subscribed
              ? localizations.detailsNewsletterResubscribeSuccessTitle
              : localizations.detailsNewsletterResubscribeFailureTitle,
          subscribed
              ? localizations
                  .detailsNewsletterResubscribeSuccessMessage(listName)
              : localizations
                  .detailsNewsletterResubscribeFailureMessage(listName),
        );
      }
    }
  }

  Future<void> _unsubscribe() async {
    final localizations = ref.text;
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName() ?? '<>';
    final confirmation = await LocalizedDialogHelper.askForConfirmation(
      ref,
      title: localizations.detailsNewsletterUnsubscribeDialogTitle,
      action: localizations.detailsNewsletterUnsubscribeDialogAction,
      query: localizations.detailsNewsletterUnsubscribeDialogQuestion(listName),
    );
    if (confirmation ?? false) {
      setState(() {
        _isActive = true;
      });
      final mailClient =
          widget.message.source.getMimeSource(widget.message)?.mailClient;
      var unsubscribed = false;
      try {
        unsubscribed = mailClient != null && await mime.unsubscribe(mailClient);
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
        // TODO(RV): store flag only when server/mailbox supports arbitrary flags?
        try {
          await mailClient?.store(
            MessageSequence.fromMessage(mime),
            [Message.keywordFlagUnsubscribed],
          );
        } catch (e, s) {
          if (kDebugMode) {
            print('error during unsubscribe flag store operation: $e $s');
          }
        }
      }
      if (context.mounted) {
        await LocalizedDialogHelper.showTextDialog(
          ref,
          unsubscribed
              ? localizations.detailsNewsletterUnsubscribeSuccessTitle
              : localizations.detailsNewsletterUnsubscribeFailureTitle,
          unsubscribed
              ? localizations
                  .detailsNewsletterUnsubscribeSuccessMessage(listName)
              : localizations
                  .detailsNewsletterUnsubscribeFailureMessage(listName),
        );
      }
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
