import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
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

  Future addAttachment() async {
    //idea: ask what to add and then call appropriate picker....
    print('pick another attachment....');
  }
}

class ComposeAttachment extends StatelessWidget {
  final AttachmentInfo attachment;
  const ComposeAttachment({Key key, @required this.attachment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child:
            // Image.memory(attachment.data,
            //     fit: BoxFit.cover, width: 60, height: 60),
            PreviewMediaWidget(
          mediaProvider:
              AttachmentMediaProviderFactory.fromAttachmentInfo(attachment),
          width: 60,
          height: 60,
          showInteractiveDelegate: (interactiveMedia) {
            return locator<NavigationService>()
                .push(Routes.interactiveMedia, arguments: interactiveMedia);
          },
        ),
      ),
    );
  }
}
