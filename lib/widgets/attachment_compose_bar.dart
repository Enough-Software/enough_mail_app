import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:enough_media/enough_media.dart';
import '../locator.dart';

class AttachmentMediaProviderFactory {
  static MediaProvider fromAttachmentInfo(AttachmentInfo info) {
    return MemoryMediaProvider(info.name, info.mediaType.text, info.data);
  }
}

class AttachmentComposeBar extends StatefulWidget {
  final ComposeData composeData;
  AttachmentComposeBar({Key key, @required this.composeData}) : super(key: key);

  @override
  _AttachmentComposeBarState createState() => _AttachmentComposeBarState();

  static Future<bool> addAttachmentTo(MessageBuilder messageBuilder) async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, withData: true);
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
    return Wrap(
      children: [
        for (final attachment in attachments) ...{
          ComposeAttachment(
            attachment: attachment,
            onRemove: removeAttachment,
          ),
        },
        ActionChip(
          avatar: Icon(Icons.add),
          visualDensity: VisualDensity.compact,
          label: Text('add'),
          onPressed: addAttachment,
        ),
      ],
    );
  }

  void removeAttachment(AttachmentInfo attachment) {
    widget.composeData.messageBuilder.removeAttachment(attachment);
    setState(() {
      attachments.remove(attachment);
    });
  }

  Future addAttachment() async {
    final added = await AttachmentComposeBar.addAttachmentTo(
        widget.composeData.messageBuilder);
    if (added) {
      setState(() {});
    }
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
            return locator<NavigationService>()
                .push(Routes.interactiveMedia, arguments: interactiveMedia);
          },
          contextMenuEntries: [
            PopupMenuItem<String>(
              child: Text('Remove ${attachment.name}'),
              value: 'remove',
            ),
          ],
          onContextMenuSelected: (provider, value) => onRemove(attachment),
        ),
      ),
    );
  }
}
