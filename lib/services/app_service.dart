import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail/message_builder.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/shared_data.dart';
import 'package:enough_mail_app/services/theme_service.dart';
import 'package:flutter/services.dart';

import '../locator.dart';
import '../routes.dart';
import 'background_service.dart';
import 'mail_service.dart';
import 'navigation_service.dart';

class AppService {
  static const _platform = const MethodChannel('app.channel.shared.data');
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;
  bool get isInBackground => (appLifecycleState != AppLifecycleState.resumed);
  Future Function(List<SharedData> sharedData) onSharedData;

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    appLifecycleState = state;
    switch (state) {
      case AppLifecycleState.resumed:
        locator<ThemeService>().checkForChangedTheme();
        final futures = [checkForShare(), locator<MailService>().resume()];
        await Future.wait(futures);
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
    //print('checkForShare: received data: $shared');
    if (shared != null) {
      composeWithSharedData(shared);
    }
  }

  Future<List<SharedData>> collectSharedData(
      Map<dynamic, dynamic> shared) async {
    final sharedData = <SharedData>[];
    final String mimeTypeText = shared['mimeType'];
    final mediaType = (mimeTypeText == null || mimeTypeText.contains('*'))
        ? null
        : MediaType.fromText(mimeTypeText);
    final int length = shared['length'];
    final String text = shared['text'];
    print('share text: "$text"');
    if (length != null && length > 0) {
      for (var i = 0; i < length; i++) {
        final String filename = shared['name.$i'];
        final Uint8List data = shared['data.$i'];
        final String typeName = shared['type.$i'];
        final localMediaType = (typeName != 'null')
            ? MediaType.fromText(typeName)
            : mediaType ?? MediaType.guessFromFileName(filename);
        sharedData.add(SharedBinary(data, filename, localMediaType));
        print(
            'share: loaded ${localMediaType.text}  "$filename" with ${data?.length} bytes');
      }
    }
    return sharedData;
    // // structure is:
    // // mimetype:[<<uri>>,<<uri>>]:text
    // final uriStartIndex = shared.indexOf(':[<<');
    // final uriEndIndex = shared.indexOf('>>]:');
    // if (uriStartIndex == -1 || uriEndIndex <= uriStartIndex) {
    //   print('invalid share: "$shared"');
    //   return data;
    // }
    // final urls = shared
    //     .substring(uriStartIndex + ':[<<'.length, uriEndIndex)
    //     .split('>>, <<');
    // print(urls);
    // if (urls.first.startsWith('mailto:')) {
    //   data.add(SharedMailto(Uri.parse(urls.first)));
    //   // builder = MessageBuilder.prepareMailtoBasedMessage(Uri.parse(urls.first),
    //   //     locator<MailService>().currentAccount.fromAddress);
    // } else {
    //   final mediaTypeText = shared.substring(0, uriStartIndex);
    //   final mediaType = (mediaTypeText != 'null' &&
    //           mediaTypeText != null &&
    //           !mediaTypeText.contains('*'))
    //       ? MediaType.fromText(mediaTypeText)
    //       : null;
    //   for (final url in urls) {
    //     if (url != 'null') {
    //       final filePath = await FlutterAbsolutePath.getAbsolutePath(url);
    //       final file = File(filePath);
    //       data.add(SharedFile(file, mediaType));
    //     }
    //   }
    // }
    // final sharedText = uriEndIndex < (shared.length - '>>]:'.length)
    //     ? shared.substring(uriEndIndex + '>>]:'.length)
    //     : null;
    // if (sharedText != null && sharedText != 'null') {
    //   data.add(SharedText(sharedText, MediaType.textPlain));
    // }

    // return data;
  }

  Future composeWithSharedData(Map<dynamic, dynamic> shared) async {
    final sharedData = await collectSharedData(shared);
    if (sharedData.isEmpty) {
      return;
    }
    if (onSharedData != null) {
      return onSharedData(sharedData);
    } else {
      MessageBuilder builder;
      final firstData = sharedData.first;
      if (firstData is SharedMailto) {
        builder = MessageBuilder.prepareMailtoBasedMessage(firstData.mailto,
            locator<MailService>().currentAccount.fromAddress);
      } else {
        builder = MessageBuilder();
        for (final data in sharedData) {
          data.addToMessageBuilder(builder);
        }
      }
      final composeData = ComposeData(null, builder, ComposeAction.newMessage);
      return locator<NavigationService>()
          .push(Routes.mailCompose, arguments: composeData, fade: true);
    }
    // structure is:
    // mimetype:[<<uri>>,<<uri>>]:text
    // final uriStartIndex = shared.indexOf(':[<<');
    // final uriEndIndex = shared.indexOf('>>]:');
    // if (uriStartIndex == -1 || uriEndIndex <= uriStartIndex) {
    //   print('invalid share: "$shared"');
    //   return Future.value();
    // }
    // final urls = shared
    //     .substring(uriStartIndex + ':[<<'.length, uriEndIndex)
    //     .split('>>, <<');
    // print(urls);
    // MessageBuilder builder;
    // if (urls.first.startsWith('mailto:')) {
    //   builder = MessageBuilder.prepareMailtoBasedMessage(Uri.parse(urls.first),
    //       locator<MailService>().currentAccount.fromAddress);
    // } else {
    //   final mediaTypeText = shared.substring(0, uriStartIndex);
    //   final mediaType = (mediaTypeText != 'null' &&
    //           mediaTypeText != null &&
    //           !mediaTypeText.contains('*'))
    //       ? MediaType.fromText(mediaTypeText)
    //       : null;
    //   builder = MessageBuilder();
    //   for (final url in urls) {
    //     if (url != 'null') {
    //       final filePath = await FlutterAbsolutePath.getAbsolutePath(url);
    //       final file = File(filePath);
    //       //final file = File.fromUri(Uri.parse(url));
    //       MediaType fileMediaType = mediaType ?? _guessMediaTypeFromFile(file);
    //       await builder.addFile(file, fileMediaType);
    //     }
    //   }
    // }
    // var sharedText = uriEndIndex < (shared.length - '>>]:'.length)
    //     ? shared.substring(uriEndIndex + '>>]:'.length)
    //     : null;
    // if (sharedText != null && sharedText != 'null') {
    //   builder.text = sharedText;
    // }
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
