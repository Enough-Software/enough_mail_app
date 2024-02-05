import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../logger.dart';
import '../models/message.dart';
import '../routes/routes.dart';
import '../screens/media_screen.dart';
import '../settings/theme/icon_service.dart';
import '../util/localized_dialog_helper.dart';
import 'ical_interactive_media.dart';

class AttachmentChip extends StatefulHookConsumerWidget {
  const AttachmentChip({super.key, required this.info, required this.message});
  final ContentInfo info;
  final Message message;

  @override
  ConsumerState<AttachmentChip> createState() => _AttachmentChipState();
}

class _AttachmentChipState extends ConsumerState<AttachmentChip> {
  MimePart? _mimePart;
  bool _isDownloading = false;
  MediaProvider? _mediaProvider;
  final _width = 72.0;
  final _height = 72.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mimeMessage = widget.message.mimeMessage;
    final mimePart = mimeMessage.getPart(widget.info.fetchId);
    _mimePart = mimePart;
    if (mimePart != null) {
      try {
        _mediaProvider =
            MimeMediaProviderFactory.fromMime(mimeMessage, mimePart);
      } catch (e, s) {
        _mediaProvider = MimeMediaProviderFactory.fromError(
          title: ref.text.errorTitle,
          text: ref.text.attachmentDecodeError(e.toString()),
        );
        logger.e(
          'Unable to decode mime-part with headers ${mimePart.headers}: $e',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaType = widget.info.contentType?.mediaType;
    final name = widget.info.fileName;
    final mediaProvider = _mediaProvider;
    if (mediaProvider == null) {
      final fallbackIcon = IconService.instance.getForMediaType(mediaType);

      return PlatformTextButton(
        onPressed: _isDownloading ? null : _download,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildPreviewWidget(true, fallbackIcon, name),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: PreviewMediaWidget(
            mediaProvider: mediaProvider,
            width: _width,
            height: _height,
            showInteractiveDelegate: _showAttachment,
            fallbackBuilder: _buildFallbackPreview,
            interactiveBuilder: _buildInteractiveMedia,
            interactiveFallbackBuilder: _buildInteractiveFallback,
            useHeroAnimation: false,
          ),
        ),
      );
    }
  }

  Widget _buildFallbackPreview(BuildContext context, MediaProvider provider) {
    final fallbackIcon = IconService.instance
        .getForMediaType(MediaType.fromText(provider.mediaType));

    return _buildPreviewWidget(false, fallbackIcon, provider.name);
  }

  Widget _buildPreviewWidget(
    bool includeDownloadOption,
    IconData iconData,
    String? name,
  ) =>
      SizedBox(
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
                    padding: const EdgeInsets.all(4),
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
                    padding: EdgeInsets.all(4),
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

  Future _download() async {
    if (_isDownloading) {
      return;
    }
    setState(() {
      _isDownloading = true;
    });
    try {
      final mimePart = await widget.message.source.fetchMessagePart(
        widget.message,
        fetchId: widget.info.fetchId,
      );
      _mimePart = mimePart;
      final mediaProvider = MimeMediaProviderFactory.fromMime(
        widget.message.mimeMessage,
        mimePart,
      );
      _mediaProvider = mediaProvider;
      final media = InteractiveMediaWidget(
        mediaProvider: mediaProvider,
        builder: _buildInteractiveMedia,
        fallbackBuilder: _buildInteractiveFallback,
      );
      await _showAttachment(media);
    } on MailException catch (e) {
      logger.e(
        'Unable to download attachment with '
        'fetch id ${widget.info.fetchId}: $e',
      );
      if (context.mounted) {
        await LocalizedDialogHelper.showTextDialog(
          ref,
          ref.text.errorTitle,
          ref.text.attachmentDownloadError(e.message ?? e.toString()),
        );
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
    if (_mimePart?.mediaType.sub == MediaSubtype.messageRfc822) {
      final mime = _mimePart?.decodeContentMessage();
      if (mime != null) {
        final message = Message.embedded(mime, widget.message);

        return context.pushNamed(
          Routes.mailDetails,
          extra: message,
        );
      }
    }

    return context.pushNamed(
      Routes.interactiveMedia,
      extra: media,
    );
  }

  Widget _buildInteractiveFallback(
    BuildContext context,
    MediaProvider mediaProvider,
  ) {
    final sizeText = ref.formatMemory(mediaProvider.size);
    final localizations = ref.text;
    final iconData = IconService.instance
        .getForMediaType(MediaType.fromText(mediaProvider.mediaType));

    return Material(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(iconData),
            ),
            Text(
              mediaProvider.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (sizeText != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(sizeText),
              ),
            PlatformTextButton(
              child: Text(localizations.attachmentActionOpen),
              onPressed: () => InteractiveMediaScreen.share(
                mediaProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildInteractiveMedia(
    BuildContext context,
    MediaProvider mediaProvider,
  ) {
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
