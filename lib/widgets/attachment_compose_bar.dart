import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/util/api_keys.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/util/http_helper.dart';
import 'package:enough_mail_app/widgets/message_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:giphy_picker/giphy_picker.dart';
import '../locator.dart';

class AttachmentMediaProviderFactory {
  static MediaProvider fromAttachmentInfo(AttachmentInfo info) {
    return MemoryMediaProvider(info.name, info.mediaType.text, info.data);
  }
}

class AttachmentComposeBar extends StatefulWidget {
  final ComposeData composeData;
  final bool isDownloading;
  AttachmentComposeBar(
      {Key key, @required this.composeData, this.isDownloading = false})
      : super(key: key);

  @override
  _AttachmentComposeBarState createState() => _AttachmentComposeBarState();
}

class _AttachmentComposeBarState extends State<AttachmentComposeBar> {
  List<AttachmentInfo> attachments;

  @override
  void initState() {
    attachments = widget.composeData.messageBuilder.attachments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);
    return Wrap(
      children: [
        for (final attachment in attachments) ...{
          ComposeAttachment(
            attachment: attachment,
            onRemove: removeAttachment,
          ),
        },
        if (widget.isDownloading) ...{
          CircularProgressIndicator(),
        },
        AddAttachmentPopupButton(
          messageBuilder: widget.composeData.messageBuilder,
          update: () => setState(() {}),
        ),
        // ActionChip(
        //   avatar: Icon(Icons.add),
        //   visualDensity: VisualDensity.compact,
        //   label: Text(localizations.composeAddAttachmentAction),
        //   onPressed: addAttachment,
        // ),
      ],
    );
  }

  void removeAttachment(AttachmentInfo attachment) {
    widget.composeData.messageBuilder.removeAttachment(attachment);
    setState(() {
      attachments.remove(attachment);
    });
  }
}

class AddAttachmentPopupButton extends StatelessWidget {
  final MessageBuilder messageBuilder;
  final Function() update;
  const AddAttachmentPopupButton(
      {Key key, @required this.messageBuilder, @required this.update})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return PopupMenuButton<int>(
      icon: Icon(Icons.add),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.insert_drive_file_outlined),
            title: Text(localizations.attachTypeFile),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.photo_outlined),
            title: Text(localizations.attachTypePhoto),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.video_collection_outlined),
            title: Text(localizations.attachTypeVideo),
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.audiotrack_outlined),
            title: Text(localizations.attachTypeAudio),
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text(localizations.attachTypeLocation),
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: ListTile(
            leading: Icon(Icons.gif),
            title: Text(localizations.attachTypeGif),
          ),
        ),
        PopupMenuItem(
          value: 6,
          child: ListTile(
            leading: Icon(MaterialCommunityIcons.sticker),
            title: Text(localizations.attachTypeSticker),
          ),
        ),
      ],
      onSelected: (value) async {
        var changed = false;
        switch (value) {
          case 0: // any file
            changed = await addAttachmentFile();
            break;
          case 1: // photo file
            changed = await addAttachmentFile(fileType: FileType.image);
            break;
          case 2: // video file
            changed = await addAttachmentFile(fileType: FileType.video);
            break;
          case 3: // audio file
            changed = await addAttachmentFile(fileType: FileType.audio);
            break;
          case 4: // location
            final result =
                await locator<NavigationService>().push(Routes.locationPicker);
            if (result != null) {
              messageBuilder.addBinary(result, MediaSubtype.imagePng.mediaType,
                  filename: "location.jpg");
              changed = true;
            }
            break;
          case 5: // gif file
            changed = await addAttachmentGif(context, localizations);
            break;
          case 6: // gif sticker file
            changed = await addAttachmentGif(context, localizations,
                searchSticker: true);
            break;
        }
        if (changed) {
          update();
        }
      },
    );
  }

  Future<bool> addAttachmentFile({FileType fileType = FileType.any}) async {
    final result = await FilePicker.platform
        .pickFiles(type: fileType, allowMultiple: true, withData: true);
    if (result == null) {
      return false;
    }
    for (final file in result.files) {
      final lastDotIndex = file.path.lastIndexOf('.');
      MediaType mediaType;
      if (lastDotIndex == -1 || lastDotIndex == file.path.length - 1) {
        mediaType = MediaType.fromSubtype(MediaSubtype.applicationOctetStream);
      } else {
        final ext = file.path.substring(lastDotIndex + 1);
        mediaType = MediaType.guessFromFileExtension(ext);
      }
      messageBuilder.addBinary(file.bytes, mediaType, filename: file.name);
    }
    return true;
  }

  Future<bool> addAttachmentGif(
      BuildContext context, AppLocalizations localizations,
      {bool searchSticker = false}) async {
    if (!ApiKeys.isInitialized) {
      await ApiKeys.init();
    }
    if (ApiKeys.giphy == null) {
      DialogHelper.showTextDialog(context, localizations.errorTitle,
          'No GIPHY API key found. Please check set up instructions.');
      return false;
    }

    final gif = await GiphyPicker.pickGif(
        context: context,
        apiKey: ApiKeys.giphy,
        searchText: searchSticker
            ? localizations.attachTypeStickerSearch
            : localizations.attachTypeGifSearch,
        lang: locator<I18nService>().locale.languageCode,
        sticker: searchSticker,
        showPreviewPage: false);
    if (gif == null) {
      return false;
    }
    final result = await HttpHelper.httpGet(gif.images.original.url);
    if (result.data == null) {
      return false;
    }
    messageBuilder.addBinary(
        result.data, MediaType.fromSubtype(MediaSubtype.imageGif),
        filename: gif.title + '.gif');

    return true;
  }
}

class ComposeAttachment extends StatelessWidget {
  final AttachmentInfo attachment;
  final void Function(AttachmentInfo attachment) onRemove;

  const ComposeAttachment(
      {Key key, @required this.attachment, @required this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: PreviewMediaWidget(
          mediaProvider:
              AttachmentMediaProviderFactory.fromAttachmentInfo(attachment),
          width: 60,
          height: 60,
          showInteractiveDelegate: (interactiveMedia) {
            if (attachment.mediaType.sub == MediaSubtype.messageRfc822) {
              final mime = MimeMessage.parseFromData(attachment.data);
              final message = Message.embedded(mime, Message.of(context));
              return locator<NavigationService>()
                  .push(Routes.mailDetails, arguments: message);
            }

            return locator<NavigationService>()
                .push(Routes.interactiveMedia, arguments: interactiveMedia);
          },
          contextMenuEntries: [
            PopupMenuItem<String>(
              child: Text(
                  localizations.composeRemoveAttachmentAction(attachment.name)),
              value: 'remove',
            ),
          ],
          onContextMenuSelected: (provider, value) => onRemove(attachment),
        ),
      ),
    );
  }
}
