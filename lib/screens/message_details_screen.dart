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
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/widgets/attachment_chip.dart';
import 'package:enough_mail_app/widgets/mail_address_chip.dart';
import 'package:enough_mail_app/widgets/message_actions.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';

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

// class MailDetailsScreen extends StatelessWidget {
//   final Message message;
//   const MailDetailsScreen({Key key, @required this.message}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return
//         // header
//         // attachments
//         // details
//         _MessageContent(message);
//     // mail actions:
//     // reply, reply all, forward, mark seen/unseen, mark spam/ham, delete, archive, redirect
//   }
// }

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

  @override
  void initState() {
    final mime = widget.message.mimeMessage;
    if (mime.isDownloaded) {
      _blockExternalImages = shouldImagesBeBlocked(mime);
    } else {
      _blockExternalImages = false;
    }
    _messageDownloadError = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message.mimeMessage;
    return Base.buildAppChrome(
      context,
      title: msg.decodeSubject() ?? '',
      content: buildMailDetails(),
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
            const PopupMenuItem<_OverflowMenuChoice>(
              value: _OverflowMenuChoice.showSourceCode,
              child: Text('View source'),
            ),
          ],
        ),
      ],
      bottom: MessageActions(message: widget.message),
    );
  }

  Widget buildMailDetails() {
    if (_messageDownloadError) {
      //TODO add retry button
      return Text('Message could not be downloaded.');
    }
    if (_showSource) {
      return SingleChildScrollView(
          child: Text(widget.message.mimeMessage.renderMessage()));
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [buildHeader(), buildContent()],
        ),
      ),
    );
  }

  Widget buildHeader() {
    final mime = widget.message.mimeMessage;
    final attachments = mime.findContentInfo();
    final date = locator<I18nService>().formatDate(mime.decodeDate(), context);
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
                  child: Text('From'),
                ),
                buildMailAddresses(mime.from)
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text('To'),
                ),
                buildMailAddresses(mime.to)
              ]),
              if (mime.cc?.isNotEmpty ?? false) ...{
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Text('CC'),
                  ),
                  buildMailAddresses(mime.cc)
                ]),
              },
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Text('Date'),
                ),
                Text(date),
              ]),
            ]),
        SelectableText(
          subject ?? '<none>',
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
                  child: Text('Show images'),
                  onPressed: () => setState(() {
                    _blockExternalImages = false;
                  }),
                ),
              },
              if (mime.isNewsletter) ...{
                if (widget.message.isNewsletterUnsubscribed) ...{
                  widget.message.isNewsLetterSubscribable
                      ? ElevatedButton(
                          child: Text('Re-subscribe'),
                          onPressed: resubscribe,
                        )
                      : Text(
                          'Unsubscribed',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                } else ...{
                  ElevatedButton(
                    child: Text('Unsubscribe'),
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
    if (false) {
      return SizedBox(
        height: 40,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: addresses.length,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: MailAddressChip(mailAddress: addresses[index]),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 2,
      runSpacing: 0,
      children: [
        for (var address in addresses) ...{buildMailAddress(address)}
      ],
    );
  }

  Widget buildMailAddress(MailAddress address) {
    return MailAddressChip(mailAddress: address);
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
    if (mimeMessage.isSeen ||
        mimeMessage.isNewsletter ||
        mimeMessage.hasAttachments() ||
        blockExternalImages) {
      setState(() {
        _blockExternalImages = blockExternalImages;
      });
    }
  }

  void onMimeMessageDownloadError(MailException e) {
    print('message could not be downloaded: $e');
    setState(() {
      _messageDownloadError = true;
    });
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
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName();
    final confirmation = await locator<AlertService>().askForConfirmation(
        context,
        title: 'Resubscribe',
        action: 'Subscribe',
        query:
            'Do you want to subscribe to this mailing list $listName again?');
    if (confirmation == true) {
      // TODO show busy indicator
      final mailClient = widget.message.mailClient;
      var unsubscribed = await mime.unsubscribe(mailClient);
      if (unsubscribed) {
        setState(() {
          widget.message.isNewsletterUnsubscribed = true;
        });
        //TODO store flag only when server/mailbox supports abritrary flags?
        await mailClient.store(MessageSequence.fromMessage(mime),
            [Message.keywordFlagUnsubscribed],
            action: StoreAction.add);
      }
      await showDialog(
        builder: (context) => AlertDialog(
          title: Text(unsubscribed ? 'Subscribed' : 'Not subscribed'),
          content: Text(unsubscribed
              ? 'You are now subscribed to the mailing list $listName.'
              : 'Sorry, but the subscribe request has failed.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
        context: context,
      );
      //locator<NavigationService>().pop();
    }
  }

  void unsubscribe() async {
    final mime = widget.message.mimeMessage;
    final listName = mime.decodeListName();
    final confirmation = await locator<AlertService>().askForConfirmation(
      context,
      title: 'Unsubscribe',
      action: 'Unsubscribe',
      query: 'Do you want to unsubscribe from this mailing list $listName?',
    );
    if (confirmation == true) {
      // TODO show busy indicator
      final mailClient = widget.message.mailClient;
      var unsubscribed = await mime.unsubscribe(mailClient);
      if (unsubscribed) {
        setState(() {
          widget.message.isNewsletterUnsubscribed = true;
        });
        //TODO store flag only when server/mailbox supports abritrary flags?
        await mailClient.store(MessageSequence.fromMessage(mime),
            [Message.keywordFlagUnsubscribed],
            action: StoreAction.add);
      }
      await showDialog(
        builder: (context) => AlertDialog(
          title: Text(unsubscribed ? 'Unsubscribed' : 'Not unsubscribed'),
          content: Text(unsubscribed
              ? 'You are now unsubscribed from the mailing list $listName.'
              : 'Sorry, but the unsubscribe request has failed.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
        context: context,
      );
      //locator<NavigationService>().pop();
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
