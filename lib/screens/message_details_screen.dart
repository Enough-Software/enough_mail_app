import 'dart:async';
import 'dart:ui';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/alert_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/widgets/attachment_chip.dart';
import 'package:enough_mail_app/widgets/mail_address_chip.dart';
import 'package:enough_mail_app/widgets/message_actions.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MessageDetailsScreen extends StatefulWidget {
  final Message message;
  const MessageDetailsScreen({Key key, @required this.message})
      : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

enum _OverflowMenuChoice { showSourceCode }

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
  bool _showSource = false;
  bool _blockExternalImages;
  bool _messageDownloadError;
  bool _messageRequiresRefresh = false;

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
      title: msg.decodeSubject() ?? '',
      content: buildMailDetails(localizations),
      appBarActions: [
        //IconButton(icon: Icon(Icons.reply), onPressed: reply),
        PopupMenuButton<_OverflowMenuChoice>(
          onSelected: (_OverflowMenuChoice result) {
            switch (result) {
              case _OverflowMenuChoice.showSourceCode:
                showSourceCode();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<_OverflowMenuChoice>(
              value: _OverflowMenuChoice.showSourceCode,
              child: Text(localizations.viewSourceAction),
            ),
          ],
        ),
      ],
      bottom: MessageActions(message: widget.message),
    );
  }

  Widget buildMailDetails(AppLocalizations localizations) {
    if (_messageDownloadError) {
      return Column(
        children: [
          Text(localizations.detailsErrorDownloadInfo),
          TextButton.icon(
            icon: Icon(Icons.refresh),
            label: Text(localizations.detailsErrorDownloadRetry),
            onPressed: () {
              setState(() {
                _messageDownloadError = false;
              });
            },
          )
        ],
      );
    }
    if (_showSource) {
      return SingleChildScrollView(
          child: SelectableText(widget.message.mimeMessage.renderMessage()));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildHeader(localizations),
          ),
          buildContent(),
        ],
      ),
    );
  }

  Widget buildHeader(AppLocalizations localizations) {
    final mime = widget.message.mimeMessage;
    final attachments = mime.findContentInfo();
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
        if (_blockExternalImages || mime.isNewsletter) ...{
          Row(
            mainAxisAlignment: _blockExternalImages
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (_blockExternalImages) ...{
                ElevatedButton(
                  child: Text(localizations.detailsActionShowImages),
                  onPressed: () => setState(() {
                    _blockExternalImages = false;
                  }),
                ),
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

  Widget buildContent() {
    return MimeMessageDownloader(
      mimeMessage: widget.message.mimeMessage,
      mailClient: widget.message.mailClient,
      markAsSeen: true,
      onDownloaded: onMimeMessageDownloaded,
      onDownloadError: onMimeMessageDownloadError,
      blockExternalImages: _blockExternalImages,
      mailtoDelegate: handleMailto,
      maxImageWidth: 320,
      showMediaDelegate: navigateToMedia,
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

  void onMimeMessageDownloadError(MailException e) {
    if (mounted) {
      setState(() {
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

  Future navigateToMedia(InteractiveMediaWidget mediaWidget) {
    return locator<NavigationService>()
        .push(Routes.interactiveMedia, arguments: mediaWidget);
  }

  void showSourceCode() {
    setState(() {
      _showSource = !_showSource;
    });
  }

  void resubscribe() async {
    final localizations = AppLocalizations.of(context);
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName();
    final confirmation = await locator<AlertService>().askForConfirmation(
        context,
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
      await locator<AlertService>().showTextDialog(
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
    final confirmation = await locator<AlertService>().askForConfirmation(
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
      await locator<AlertService>().showTextDialog(
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
