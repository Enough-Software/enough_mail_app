import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/media_screen.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/ical_interactive_media.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';

import 'button_text.dart';

class AttachmentChip extends StatefulWidget {
  const AttachmentChip({Key? key, required this.info, required this.message})
      : super(key: key);
  final ContentInfo info;
  final Message message;

  @override
  State<AttachmentChip> createState() => _AttachmentChipState();
}

class _AttachmentChipState extends State<AttachmentChip> {
  MimePart? _mimePart;
  bool _isDownloading = false;
  MediaProvider? _mediaProvider;
  final _width = 72.0;
  final _height = 72.0;

  @override
  void initState() {
    final mimeMessage = widget.message.mimeMessage;
    _mimePart = mimeMessage.getPart(widget.info.fetchId);
    if (_mimePart != null) {
      _mediaProvider =
          MimeMediaProviderFactory.fromMime(mimeMessage, _mimePart!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaType = widget.info.contentType?.mediaType;
    final name = widget.info.fileName;
    if (_mediaProvider == null) {
      final fallbackIcon = locator<IconService>().getForMediaType(mediaType);
      return PlatformTextButton(
        onPressed: _isDownloading ? null : _download,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: _buildPreviewWidget(true, fallbackIcon, name),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: PreviewMediaWidget(
            mediaProvider: _mediaProvider!,
            width: _width,
            height: _height,
            showInteractiveDelegate: _showAttachment,
            fallbackBuilder: _buildFallbackPreview,
            interactiveBuilder: _buildInteractiveMedia,
            interactiveFallbackBuilder: _buildInteractiveFallback,
          ),
        ),
      );
    }
  }

  Widget _buildFallbackPreview(BuildContext context, MediaProvider provider) {
    final fallbackIcon = locator<IconService>()
        .getForMediaType(MediaType.fromText(provider.mediaType));
    return _buildPreviewWidget(false, fallbackIcon, provider.name);
  }

  Widget _buildPreviewWidget(
      bool includeDownloadOption, IconData iconData, String? name) {
    return SizedBox(
      width: _width,
      height: _height,
      //color: Colors.yellow,
      child: Stack(
        children: [
          Icon(
            iconData,
            size: _width,
            color: Colors.grey[700],
          ),
          if (name != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: _width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xff000000)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    name,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ),
              ),
            ),
          if (includeDownloadOption) ...[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: _width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0x00000000), Color(0xff000000)],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.download_rounded, color: Colors.white),
                ),
              ),
            ),
            if (_isDownloading)
              const Center(child: PlatformProgressIndicator()),
          ],
        ],
      ),
    );
    // Container(
    //   width: 80,
    //   height: 80,
    //   child: ActionChip(
    //     avatar: buildIcon(),
    //     visualDensity: VisualDensity.compact,
    //     label: Text(widget.info.fileName, style: TextStyle(fontSize: 8)),
    //     onPressed: download,
    //   ),
    // );
  }

  Future _download() async {
    if (_isDownloading) {
      return;
    }
    setState(() {
      _isDownloading = true;
    });
    try {
      _mimePart = await widget.message.mailClient
          .fetchMessagePart(widget.message.mimeMessage, widget.info.fetchId);
      _mediaProvider = MimeMediaProviderFactory.fromMime(
          widget.message.mimeMessage, _mimePart!);
      final media = InteractiveMediaWidget(
        mediaProvider: _mediaProvider!,
        builder: _buildInteractiveMedia,
        fallbackBuilder: _buildInteractiveFallback,
      );
      _showAttachment(media);
    } on MailException catch (e) {
      if (kDebugMode) {
        print(
            'Unable to download attachment with fetch id ${widget.info.fetchId}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future _showAttachment(InteractiveMediaWidget media) {
    if (_mimePart!.mediaType.sub == MediaSubtype.messageRfc822) {
      final mime = _mimePart!.decodeContentMessage();
      if (mime != null) {
        final message = Message.embedded(mime, widget.message);
        return locator<NavigationService>()
            .push(Routes.mailDetails, arguments: message);
      }
    }
    return locator<NavigationService>()
        .push(Routes.interactiveMedia, arguments: media);
  }

  Widget _buildInteractiveFallback(
      BuildContext context, MediaProvider mediaProvider) {
    final sizeText = locator<I18nService>().formatMemory(mediaProvider.size);
    final localizations = AppLocalizations.of(context)!;
    final iconData = locator<IconService>()
        .getForMediaType(MediaType.fromText(mediaProvider.mediaType));

    return Material(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(iconData),
            ),
            Text(
              mediaProvider.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            if (sizeText != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(sizeText),
              ),
            PlatformTextButton(
              child: ButtonText(localizations.attachmentActionOpen),
              onPressed: () => InteractiveMediaScreen.share(mediaProvider),
            )
          ],
        ),
      ),
    );
  }

  Widget? _buildInteractiveMedia(
      BuildContext context, MediaProvider mediaProvider) {
    if (mediaProvider.mediaType == 'text/calendar' ||
        mediaProvider.mediaType == 'application/ics') {
      return IcalInteractiveMedia(
        mediaProvider: mediaProvider,
        message: widget.message,
      );
    }
    return null;
  }
}
