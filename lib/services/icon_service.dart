import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class IconService {
  IconData getForMediaType(MediaType mediaType) {
    if (mediaType == null) {
      return Icons.attachment;
    }
    switch (mediaType.top) {
      case MediaToptype.text:
        return Icons.short_text;

      case MediaToptype.image:
        return Icons.image;

      case MediaToptype.audio:
        return Icons.audiotrack;

      case MediaToptype.video:
        return Icons.ondemand_video;

      case MediaToptype.application:
        return Icons.apps;

      case MediaToptype.multipart:
        return Icons.apps;

      case MediaToptype.message:
        return Icons.message;

      case MediaToptype.model:
        return Icons.attachment;

      case MediaToptype.font:
        return Icons.font_download;

      case MediaToptype.other:
        return Icons.attachment;
      default:
        return Icons.attachment;
    }
  }

  IconData getForMailbox(Mailbox mailbox) {
    var iconData = MaterialCommunityIcons.folder_outline;
    if (mailbox.isInbox) {
      iconData = MaterialCommunityIcons.inbox;
    } else if (mailbox.isDrafts) {
      iconData = MaterialCommunityIcons.email_edit_outline;
    } else if (mailbox.isTrash) {
      iconData = MaterialCommunityIcons.trash_can_outline;
    } else if (mailbox.isSent) {
      iconData = MaterialCommunityIcons.inbox_arrow_up;
    } else if (mailbox.isArchive) {
      iconData = MaterialCommunityIcons.archive;
    } else if (mailbox.isJunk) {
      iconData = Entypo.bug;
    }
    return iconData;
  }

  static Widget buildNumericIcon(int value, {double size}) {
    switch (value) {
      case 1:
        return Icon(
          Icons.looks_one_outlined,
          size: size,
        );
      case 2:
        return Icon(Icons.looks_two_outlined, size: size);
      case 3:
        return Icon(Icons.looks_3_outlined, size: size);
      case 4:
        return Icon(Icons.looks_4_outlined, size: size);
      case 5:
        return Icon(Icons.looks_5_outlined, size: size);
      case 6:
        return Icon(Icons.looks_6_outlined, size: size);
      default:
        final style = size == null ? null : TextStyle(fontSize: (size * 0.8));
        return Container(
          decoration: BoxDecoration(border: Border.all()),
          child: Text(value.toString(), style: style),
        );
    }
  }
}
