import 'dart:io';
import 'dart:ui';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail/message_builder.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

import '../locator.dart';
import '../routes.dart';
import 'background_service.dart';
import 'mail_service.dart';
import 'navigation_service.dart';

class AppService {
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;
  bool get isInBackground => (appLifecycleState != AppLifecycleState.resumed);
  static const _platform = const MethodChannel('app.channel.shared.data');

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    appLifecycleState = state;
    switch (state) {
      case AppLifecycleState.resumed:
        await checkForShare();
        await locator<MailService>().resume();
        break;
      case AppLifecycleState.inactive:
        // TODO: Check if AppLifecycleState.inactive needs to be handled
        break;
      case AppLifecycleState.paused:
        await locator<BackgroundService>().saveStateOnPause();
        break;
      case AppLifecycleState.detached:
        // TODO: Check if AppLifecycleState.detached needs to be handled
        break;
    }
  }

  Future checkForShare() async {
    final shared = await _platform.invokeMethod("getSharedData");
    print('checkForShare: received data: $shared');
    if (shared != null) {
      composeWithSharedData(shared);
    }
  }

  Future composeWithSharedData(String shared) async {
    // structure is:
    // mimetype:[<<uri>>,<<uri>>]:text
    final uriStartIndex = shared.indexOf(':[<<');
    final uriEndIndex = shared.indexOf('>>]:');
    if (uriStartIndex == -1 || uriEndIndex <= uriStartIndex) {
      print('invalid share: "$shared"');
      return Future.value();
    }
    final urls = shared
        .substring(uriStartIndex + ':[<<'.length, uriEndIndex)
        .split('>>, <<');
    print(urls);
    MessageBuilder builder;
    if (urls.first.startsWith('mailto:')) {
      builder = MessageBuilder.prepareMailtoBasedMessage(Uri.parse(urls.first),
          locator<MailService>().currentAccount.fromAddress);
    } else {
      final mediaTypeText = shared.substring(0, uriStartIndex);
      final mediaType = (mediaTypeText != 'null' &&
              mediaTypeText != null &&
              !mediaTypeText.contains('*'))
          ? MediaType.fromText(mediaTypeText)
          : null;
      builder = MessageBuilder();
      for (final url in urls) {
        final filePath = await FlutterAbsolutePath.getAbsolutePath(url);
        final file = File(filePath);
        //final file = File.fromUri(Uri.parse(url));
        MediaType fileMediaType = mediaType ?? _guessMediaTypeFromFile(file);
        await builder.addFile(file, fileMediaType);
      }
    }
    var sharedText = uriEndIndex < (shared.length - '>>]:'.length)
        ? shared.substring(uriEndIndex + '>>]:'.length)
        : null;
    if (sharedText != null && sharedText != 'null') {
      builder.text = sharedText;
    }

    final composeData = ComposeData(null, builder, ComposeAction.newMessage);
    return locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData, fade: true);
  }

  MediaType _guessMediaTypeFromFile(File file) {
    print('guess media type for "${file.path}"...');
    final extIndex = file.path.lastIndexOf('.');
    if (extIndex != -1) {
      final ext = file.path.substring(extIndex + 1);
      return MediaType.guessFromFileExtension(ext);
    }
    return MediaType.fromSubtype(MediaSubtype.applicationOctetStream);
  }
}
