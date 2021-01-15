import 'dart:io';

import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;

class MediaScreen extends StatelessWidget {
  final MediaViewer mediaViewer;

  const MediaScreen({Key key, this.mediaViewer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: mediaViewer.mimeMessage.decodeSubject(),
      content: mediaViewer,
      appBarActions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: share,
        ),
      ],
    );
  }

  void share() async {
    final tempDir = await pathprovider.getTemporaryDirectory();
    final originalFileName = mediaViewer.mimePart.decodeFileName() ??
        'unknown_${DateTime.now().millisecondsSinceEpoch}';
    final lastDotIndex = originalFileName.lastIndexOf('.');
    final ext =
        lastDotIndex != -1 ? originalFileName.substring(lastDotIndex) : '';
    final safeFileName = filterNonAscii(originalFileName);
    final path = '${tempDir.path}/$safeFileName$ext';
    final file = File(path);
    await file.writeAsBytes(mediaViewer.mimePart.decodeContentBinary());

    final paths = [path];
    final mimeTypes =
        mediaViewer.mediaType != null ? [mediaViewer.mediaType.text] : null;
    await Share.shareFiles(paths,
        mimeTypes: mimeTypes,
        subject: originalFileName,
        text: mediaViewer.mimeMessage.decodeSubject());
  }

  static String filterNonAscii(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if ((rune >= 48 && rune <= 57) || // 0-9
          (rune >= 65 && rune <= 90) || // A-Z
          (rune >= 97 && rune <= 122)) // a-z
      {
        buffer.writeCharCode(rune);
      } else if (rune == 46) {
        // dot / period
        break;
      } else {
        buffer.write('_');
      }
    }
    return buffer.toString();
  }
}
