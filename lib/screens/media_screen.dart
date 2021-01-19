import 'dart:io';

import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;

import '../locator.dart';

class InteractiveMediaScreen extends StatelessWidget {
  final InteractiveMediaWidget mediaWidget;

  const InteractiveMediaScreen({Key key, this.mediaWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: mediaWidget.mediaProvider.name,
      content: mediaWidget,
      appBarActions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: share,
        ),
      ],
    );
  }

  void share() async {
    final provider = mediaWidget.mediaProvider;
    if (provider is TextMediaProvider) {
      await shareText(provider);
    } else if (provider is MemoryMediaProvider) {
      shareFile(provider);
    }
  }

  Future shareText(TextMediaProvider provider) async {
    await Share.share(provider.text,
        subject: provider.description ?? provider.name);
  }

  Future shareFile(MemoryMediaProvider provider) async {
    final tempDir = await pathprovider.getTemporaryDirectory();
    final originalFileName =
        provider.name ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    final lastDotIndex = originalFileName.lastIndexOf('.');
    final ext =
        lastDotIndex != -1 ? originalFileName.substring(lastDotIndex) : '';
    final safeFileName = filterNonAscii(originalFileName);
    final path = '${tempDir.path}/$safeFileName$ext';
    final file = File(path);
    await file.writeAsBytes(provider.data);

    final paths = [path];
    final mimeTypes = provider.mediaType != null ? [provider.mediaType] : null;
    await Share.shareFiles(paths,
        mimeTypes: mimeTypes,
        subject: originalFileName,
        text: provider.description);
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
