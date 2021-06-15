import 'package:community_material_icon/community_material_icon.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

class IconService {
  IconData getMessageIsSeen(bool isSeen) =>
      isSeen ? messageIsSeen : messageIsNotSeen;
  IconData get messageIsSeen => Icons.circle_outlined;
  IconData get messageIsNotSeen => Icons.circle;
  IconData getMessageIsFlagged(bool isFlagged) =>
      isFlagged ? messageIsFlagged : messageIsNotFlagged;
  IconData get messageIsFlagged => Icons.flag;
  IconData get messageIsNotFlagged => Icons.flag_outlined;

  IconData get messageActionReply => Icons.reply;
  IconData get messageActionReplyAll => Icons.reply_all;
  IconData get messageActionForward => Icons.forward;
  IconData get messageActionForwardAsAttachment => Icons.forward_to_inbox;
  IconData get messageActionForwardAttachments => Icons.attach_file;
  IconData get messageActionMoveToInbox => Icons.move_to_inbox;
  IconData get messageActionDelete => CommunityMaterialIcons.trash_can_outline;
  IconData get messageActionMove => CommunityMaterialIcons.file_move_outline;
  IconData get messageActionMoveToJunk => CommunityMaterialIcons.bug_outline;
  IconData get messageActionMoveFromJunkToInbox => Icons.check;
  IconData get messageActionArchive => CommunityMaterialIcons.archive_outline;
  IconData get messageActionRedirect => Icons.compare_arrows;

  IconData get folderGeneric => CommunityMaterialIcons.folder_outline;
  IconData get folderInbox => CommunityMaterialIcons.inbox;
  IconData get folderDrafts => CommunityMaterialIcons.email_edit_outline;
  IconData get folderTrash => CommunityMaterialIcons.trash_can_outline;
  IconData get folderSent => CommunityMaterialIcons.inbox_arrow_up;
  IconData get folderArchive => CommunityMaterialIcons.archive_outline;
  IconData get folderJunk => CommunityMaterialIcons.bug_outline;

  IconData getForMediaType(MediaType? mediaType) {
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
    var iconData = folderGeneric;
    if (mailbox.isInbox) {
      iconData = folderInbox;
    } else if (mailbox.isDrafts) {
      iconData = folderDrafts;
    } else if (mailbox.isTrash) {
      iconData = folderTrash;
    } else if (mailbox.isSent) {
      iconData = folderSent;
    } else if (mailbox.isArchive) {
      iconData = folderArchive;
    } else if (mailbox.isJunk) {
      iconData = folderJunk;
    }
    return iconData;
  }

  static Widget buildNumericIcon(int value, {double? size}) {
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
