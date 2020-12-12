import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/services/scaffold_service.dart';
import 'package:flutter/material.dart';

class AttachmentChip extends StatefulWidget {
  final ContentInfo info;
  final Message message;
  AttachmentChip({Key key, @required this.info, @required this.message})
      : super(key: key);

  @override
  _AttachmentChipState createState() => _AttachmentChipState();
}

class _AttachmentChipState extends State<AttachmentChip> {
  MimePart _mimePart;
  bool _isDownloading = false;

  @override
  void initState() {
    _mimePart = widget.message.mimeMessage.getPart(widget.info.fetchId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: buildIcon(),
      visualDensity: VisualDensity.compact,
      label: Text(widget.info.fileName),
      onPressed: handleTap,
    );
  }

  void handleTap() async {
    if (_mimePart == null) {
      if (_isDownloading) {
        return;
      }
      setState(() {
        _isDownloading = true;
      });
      var response = await widget.message.mailClient
          .fetchMessagePart(widget.message.mimeMessage, widget.info.fetchId);
      if (response.isOkStatus) {
        _mimePart = response.result;
        setState(() {
          _isDownloading = false;
        });
        showAttachment();
      }
    } else {
      showAttachment();
    }
  }

  void showAttachment() {
    //TODO open attachment view
    if (widget.info.contentType?.mediaType?.top == MediaToptype.image) {
      var imageData = _mimePart.decodeContentBinary();
      _showDialog(buildImageDialog(Image.memory(imageData)));
    } else {
      _showTextDialog('${widget.info.fileName} cannot be shown');
    }
  }

  Widget buildImageDialog(Image image) {
    return AlertDialog(
      content: image,
      actions: [
        FlatButton(
          child: Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _showDialog(Widget dialog) {
    showDialog(
      context: context,
      builder: (_) => dialog,
    );
  }

  void _showTextDialog(String text) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Material Dialog"),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close me!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Widget buildIcon() {
    if (_isDownloading) {
      return CircularProgressIndicator();
    }
    final mediaType = widget.info.contentType?.mediaType?.top;
    IconData icon;
    if (mediaType == null) {
      icon = Icons.attachment;
    } else {
      switch (mediaType) {
        case MediaToptype.text:
          icon = Icons.short_text;
          break;
        case MediaToptype.image:
          icon = Icons.image;
          break;
        case MediaToptype.audio:
          icon = Icons.audiotrack;
          break;
        case MediaToptype.video:
          icon = Icons.personal_video;
          break;
        case MediaToptype.application:
          icon = Icons.apps;
          break;
        case MediaToptype.multipart:
          icon = Icons.apps;
          break;
        case MediaToptype.message:
          icon = Icons.message;
          break;
        case MediaToptype.model:
          icon = Icons.attachment;
          break;
        case MediaToptype.font:
          icon = Icons.font_download;
          break;
        case MediaToptype.other:
          icon = Icons.attachment;
          break;
      }
    }

    return Icon(icon);
  }
}
