import 'package:community_material_icon/community_material_icon.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconService {
  static final _isCupertino = PlatformInfo.isCupertino;

  IconData get share => _isCupertino ? CupertinoIcons.share : Icons.share;
  IconData get location =>
      _isCupertino ? CupertinoIcons.location : Icons.location_on_outlined;
  IconData get email => _isCupertino ? CupertinoIcons.mail : Icons.email;
  IconData get settings =>
      _isCupertino ? CupertinoIcons.settings : Icons.settings;
  IconData get about => _isCupertino ? CupertinoIcons.info : Icons.info_outline;

  IconData get mediaFile =>
      _isCupertino ? CupertinoIcons.doc : Icons.insert_drive_file_outlined;
  IconData get mediaPhoto =>
      _isCupertino ? CupertinoIcons.photo : Icons.photo_outlined;
  IconData get mediaAudio =>
      _isCupertino ? CupertinoIcons.music_note : Icons.audiotrack_outlined;
  IconData get mediaVideo =>
      _isCupertino ? CupertinoIcons.videocam : Icons.video_collection_outlined;
  IconData get mediaGif => Icons.gif;
  IconData get mediaSticker => CommunityMaterialIcons.sticker;
  IconData get appointment =>
      _isCupertino ? CupertinoIcons.calendar : Icons.calendar_today;

  IconData get add => _isCupertino ? CupertinoIcons.add : Icons.add;

  IconData get retry =>
      _isCupertino ? CupertinoIcons.arrow_clockwise : Icons.repeat;

  IconData getMessageIsSeen(bool isSeen) =>
      isSeen ? messageIsSeen : messageIsNotSeen;
  IconData get messageIsSeen =>
      _isCupertino ? CupertinoIcons.circle : Icons.circle_outlined;
  IconData get messageIsNotSeen =>
      _isCupertino ? CupertinoIcons.circle_fill : Icons.circle;
  IconData getMessageIsFlagged(bool isFlagged) =>
      isFlagged ? messageIsFlagged : messageIsNotFlagged;
  IconData get messageIsFlagged =>
      _isCupertino ? CupertinoIcons.flag_fill : Icons.flag;
  IconData get messageIsNotFlagged =>
      _isCupertino ? CupertinoIcons.flag : Icons.flag_outlined;

  IconData get messageActionReply =>
      _isCupertino ? CupertinoIcons.reply : Icons.reply;
  IconData get messageActionReplyAll =>
      _isCupertino ? CupertinoIcons.reply_all : Icons.reply_all;
  IconData get messageActionForward =>
      _isCupertino ? CupertinoIcons.arrowshape_turn_up_right : Icons.forward;
  IconData get messageActionForwardAsAttachment => Icons.forward_to_inbox;
  IconData get messageActionForwardAttachments => Icons.attach_file;
  IconData get messageActionMoveToInbox => Icons.move_to_inbox;
  IconData get messageActionDelete => _isCupertino
      ? CupertinoIcons.delete
      : CommunityMaterialIcons.trash_can_outline;
  IconData get messageActionMove => _isCupertino
      ? CupertinoIcons.folder
      : CommunityMaterialIcons.file_move_outline;
  IconData get messageActionMoveToJunk => CommunityMaterialIcons.bug_outline;
  IconData get messageActionMoveFromJunkToInbox =>
      _isCupertino ? CupertinoIcons.checkmark : Icons.check;
  IconData get messageActionArchive => _isCupertino
      ? CupertinoIcons.archivebox
      : CommunityMaterialIcons.archive_outline;
  IconData get messageActionRedirect =>
      _isCupertino ? CupertinoIcons.arrow_branch : Icons.compare_arrows;
  IconData get messageActionViewInSafeMode =>
      _isCupertino ? CupertinoIcons.lock : Icons.lock;
  IconData get messageActionAddNotification =>
      _isCupertino ? CupertinoIcons.alarm : Icons.notification_add;

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

  static Widget buildNumericIcon(BuildContext context, int value,
      {double? size}) {
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
        final borderColor = (Theme.of(context).brightness == Brightness.dark)
            ? const Color(0xffeeeeee)
            : const Color(0xff000000);
        return Container(
          decoration: BoxDecoration(border: Border.all(color: borderColor)),
          child: Text(value.toString(), style: style),
        );
    }
  }
}
