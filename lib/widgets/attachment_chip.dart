import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_media/enough_media.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

class AttachmentChip extends StatefulWidget {
  final ContentInfo info;
  final Message? message;
  AttachmentChip({Key? key, required this.info, required this.message})
      : super(key: key);

  @override
  _AttachmentChipState createState() => _AttachmentChipState();
}

class _AttachmentChipState extends State<AttachmentChip> {
  MimePart? _mimePart;
  bool _isDownloading = false;
  MediaProvider? _mediaProvider;
  final _width = 72.0;
  final _height = 72.0;

  @override
  void initState() {
    final mimeMessage = widget.message!.mimeMessage!;
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
      return PlatformButton(
        materialFlat: (context, platform) =>
            MaterialFlatButtonData(padding: EdgeInsets.zero),
        onPressed: _isDownloading ? null : download,
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
            showInteractiveDelegate: showAttachment,
            fallbackBuilder: _buildFallbackPreview,
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
    return Container(
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
          if (name != null) ...{
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: _width,
                decoration: BoxDecoration(
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
                    style: TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ),
              ),
            ),
          },
          if (includeDownloadOption) ...{
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: _width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0x00000000), Color(0xff000000)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.download_rounded, color: Colors.white),
                ),
              ),
            ),
            if (_isDownloading) ...{
              Center(child: PlatformProgressIndicator()),
            },
          }
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

  Future download() async {
    if (_isDownloading) {
      return;
    }
    setState(() {
      _isDownloading = true;
    });
    try {
      _mimePart = await widget.message!.mailClient
          .fetchMessagePart(widget.message!.mimeMessage!, widget.info.fetchId);
      _mediaProvider = MimeMediaProviderFactory.fromMime(
          widget.message!.mimeMessage!, _mimePart!);
      final media = InteractiveMediaWidget(mediaProvider: _mediaProvider!);
      showAttachment(media);
    } on MailException catch (e) {
      print(
          'Unable to download attachment with fetch id ${widget.info.fetchId}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future showAttachment(InteractiveMediaWidget media) {
    if (_mimePart!.mediaType.sub == MediaSubtype.messageRfc822) {
      final mime = _mimePart!.decodeContentMessage();
      if (mime != null) {
        final message = Message.embedded(mime, widget.message!);
        return locator<NavigationService>()
            .push(Routes.mailDetails, arguments: message);
      }
    }
    return locator<NavigationService>()
        .push(Routes.interactiveMedia, arguments: media);
  }

  Widget buildIcon() {
    if (_isDownloading) {
      return PlatformProgressIndicator();
    }
    final mediaType = widget.info.contentType?.mediaType;
    IconData icon = locator<IconService>().getForMediaType(mediaType);
    final color = (_mimePart != null) ? Colors.black : Colors.grey[700];
    return Icon(icon, color: color);
  }
}
