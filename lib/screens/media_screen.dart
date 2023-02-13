import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_media/enough_media.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import '../routes.dart';

enum _OverflowMenuChoice {
  showAsEmail,
}

class InteractiveMediaScreen extends StatelessWidget {
  final InteractiveMediaWidget mediaWidget;

  const InteractiveMediaScreen({Key? key, required this.mediaWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final iconService = locator<IconService>();
    return Base.buildAppChrome(
      context,
      title: mediaWidget.mediaProvider.name,
      content: mediaWidget,
      appBarActions: [
        DensePlatformIconButton(
          icon: Icon(iconService.messageActionForward),
          onPressed: _forward,
        ),
        DensePlatformIconButton(
          icon: Icon(iconService.share),
          onPressed: _share,
        ),
        if (mediaWidget.mediaProvider.isText &&
            locator<SettingsService>().settings.enableDeveloperMode)
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
                      final mailService = locator<MailService>();
                      final account = mailService.currentAccount;
                      if (account is RealAccount) {
                        final client = await mailService.getClientFor(account);
                        final source =
                            SingleMessageSource(mailService.messageSource);
                        final message = Message(mime, client, source, 0);
                        message.isEmbedded = true;
                        source.singleMessage = message;
                        showErrorMessage = false;
                        locator<NavigationService>()
                            .push(Routes.mailDetails, arguments: message);
                      }
                    }
                  } catch (e, s) {
                    if (kDebugMode) {
                      print('Unable to convert text into mime: $e $s');
                    }
                  }
                  if (showErrorMessage) {
                    LocalizedDialogHelper.showTextDialog(
                        context,
                        localizations.errorTitle,
                        localizations.developerShowAsEmailFailed);
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

  void _forward() {
    final provider = mediaWidget.mediaProvider;
    final messageBuilder = MessageBuilder()..subject = provider.name;

    if (provider is TextMediaProvider) {
      messageBuilder.addBinary(utf8.encode(provider.text) as Uint8List,
          MediaType.fromText(provider.mediaType),
          filename: provider.name);
    } else if (provider is MemoryMediaProvider) {
      messageBuilder.addBinary(
          provider.data, MediaType.fromText(provider.mediaType),
          filename: provider.name);
    }
    final composeData =
        ComposeData(null, messageBuilder, ComposeAction.newMessage);
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData);
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
