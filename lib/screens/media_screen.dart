import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_media/enough_media.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;
import 'package:share_plus/share_plus.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../localization/extension.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../models/message_source.dart';
import '../routes.dart';
import '../settings/provider.dart';
import '../settings/theme/icon_service.dart';
import '../util/localized_dialog_helper.dart';
import 'base.dart';

enum _OverflowMenuChoice {
  showAsEmail,
}

class InteractiveMediaScreen extends ConsumerWidget {
  const InteractiveMediaScreen({super.key, required this.mediaWidget});
  final InteractiveMediaWidget mediaWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.text;
    final iconService = IconService.instance;

    return BasePage(
      title: mediaWidget.mediaProvider.name,
      content: mediaWidget,
      appBarActions: [
        DensePlatformIconButton(
          icon: Icon(iconService.messageActionForward),
          onPressed: () => _forward(context),
        ),
        DensePlatformIconButton(
          icon: Icon(iconService.share),
          onPressed: _share,
        ),
        if (mediaWidget.mediaProvider.isText &&
            ref.read(settingsProvider).enableDeveloperMode)
          PlatformPopupMenuButton<_OverflowMenuChoice>(
            onSelected: (_OverflowMenuChoice result) async {
              switch (result) {
                case _OverflowMenuChoice.showAsEmail:
                  final provider = mediaWidget.mediaProvider;
                  var showErrorMessage = true;
                  try {
                    MimeMessage? mime;
                    if (provider is TextMediaProvider) {
                      mime = MimeMessage.parseFromText(provider.text);
                    } else if (provider is MemoryMediaProvider) {
                      mime = MimeMessage.parseFromData(provider.data);
                    }
                    if (mime != null) {
                      final account = ref.read(currentAccountProvider);
                      if (account is RealAccount) {
                        final source = SingleMessageSource(
                          null,
                          account: account,
                        );
                        final message = Message(mime, source, 0)
                          ..isEmbedded = true;
                        source.singleMessage = message;
                        showErrorMessage = false;
                        unawaited(
                          context.pushNamed(Routes.mailDetails, extra: message),
                        );
                      }
                    }
                  } catch (e, s) {
                    if (kDebugMode) {
                      print('Unable to convert text into mime: $e $s');
                    }
                  }
                  if (showErrorMessage) {
                    if (context.mounted) {
                      await LocalizedDialogHelper.showTextDialog(
                        context,
                        localizations.errorTitle,
                        localizations.developerShowAsEmailFailed,
                      );
                    }
                  }

                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PlatformPopupMenuItem<_OverflowMenuChoice>(
                value: _OverflowMenuChoice.showAsEmail,
                child: Text(localizations.developerShowAsEmail),
              ),
            ],
          ),
      ],
    );
  }

  void _forward(BuildContext context) {
    final provider = mediaWidget.mediaProvider;
    final messageBuilder = MessageBuilder()..subject = provider.name;

    if (provider is TextMediaProvider) {
      messageBuilder.addBinary(
        utf8.encode(provider.text) as Uint8List,
        MediaType.fromText(provider.mediaType),
        filename: provider.name,
      );
    } else if (provider is MemoryMediaProvider) {
      messageBuilder.addBinary(
        provider.data,
        MediaType.fromText(provider.mediaType),
        filename: provider.name,
      );
    }
    final composeData =
        ComposeData(null, messageBuilder, ComposeAction.newMessage);
    context.pushNamed(Routes.mailCompose, extra: composeData);
  }

  void _share() {
    final provider = mediaWidget.mediaProvider;
    share(provider);
  }

  static Future share(MediaProvider provider) {
    if (provider is TextMediaProvider) {
      return _shareText(provider);
    } else if (provider is MemoryMediaProvider) {
      return _shareFile(provider);
    } else {
      if (kDebugMode) {
        print('Unable to share media provider $provider');
      }
      return Future.value();
    }
  }

  static Future _shareText(TextMediaProvider provider) async {
    await Share.share(provider.text,
        subject: provider.description ?? provider.name);
  }

  static Future _shareFile(MemoryMediaProvider provider) async {
    final tempDir = await pathprovider.getTemporaryDirectory();
    final originalFileName = provider.name;
    final lastDotIndex = originalFileName.lastIndexOf('.');
    final ext =
        lastDotIndex != -1 ? originalFileName.substring(lastDotIndex) : '';
    final safeFileName = _filterNonAscii(originalFileName);
    final path = '${tempDir.path}/$safeFileName$ext';
    final file = File(path);
    await file.writeAsBytes(provider.data);

    final paths = [path];
    final mimeTypes = [provider.mediaType];
    await Share.shareFiles(paths,
        mimeTypes: mimeTypes,
        subject: originalFileName,
        text: provider.description);
  }

  static String _filterNonAscii(String input) {
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
