import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

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
        return Icons.personal_video;

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
}
