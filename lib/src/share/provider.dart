import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../account/provider.dart';
import '../app_lifecycle/provider.dart';
import '../logger.dart';
import '../models/compose_data.dart';
import '../routes/routes.dart';
import 'model.dart';

part 'provider.g.dart';

/// Callback to register a share handler
typedef SharedDataCallback = Future<void> Function(List<SharedData> sharedData);

/// Allows to registered shared data callbacks
SharedDataCallback? onSharedData;

/// Handles incoming shares
@Riverpod(keepAlive: true)
class IncomingShare extends _$IncomingShare {
  static const _platform = MethodChannel('app.channel.shared.data');
  var _isFirstBuild = true;

  @override
  Future<void> build() async {
    final isResumed = ref.watch(rawAppLifecycleStateProvider
        .select((value) => value == AppLifecycleState.resumed));
    if (isResumed) {
      if (Platform.isAndroid) {
        final shared = await _platform.invokeMethod('getSharedData');
        logger.d('checkForShare: received data: $shared');
        if (shared != null) {
          if (_isFirstBuild) {
            _isFirstBuild = false;
            await Future.delayed(const Duration(seconds: 2));
          }
          await _composeWithSharedData(shared);
        }
      }
    }
  }

  Future<void> _composeWithSharedData(
    Map<dynamic, dynamic> shared,
  ) async {
    final sharedData = await _collectSharedData(shared);
    if (sharedData.isEmpty) {
      return;
    }
    final callback = onSharedData;
    if (callback != null) {
      return callback(sharedData);
    } else {
      MessageBuilder builder;
      final firstData = sharedData.first;
      final account = ref.read(currentRealAccountProvider);
      if (firstData is SharedMailto && account != null) {
        builder = MessageBuilder.prepareMailtoBasedMessage(
          firstData.mailto,
          account.fromAddress,
        );
      } else {
        builder = MessageBuilder();
        for (final data in sharedData) {
          await data.addToMessageBuilder(builder);
        }
      }
      final composeData = ComposeData(null, builder, ComposeAction.newMessage);
      final context = Routes.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        unawaited(context.pushNamed(Routes.mailCompose, extra: composeData));
      }
    }
  }

  Future<List<SharedData>> _collectSharedData(
    Map<dynamic, dynamic> shared,
  ) async {
    final sharedData = <SharedData>[];
    final String? mimeTypeText = shared['mimeType'];
    final mediaType = (mimeTypeText == null || mimeTypeText.contains('*'))
        ? null
        : MediaType.fromText(mimeTypeText);
    final int? length = shared['length'];
    final String? text = shared['text'];
    if (kDebugMode) {
      print('share text: "$text"');
    }
    if (length != null && length > 0) {
      for (var i = 0; i < length; i++) {
        final String? filename = shared['name.$i'];
        final Uint8List? data = shared['data.$i'];
        final String? typeName = shared['type.$i'];
        final localMediaType = (typeName != null && typeName != 'null')
            ? MediaType.fromText(typeName)
            : mediaType ??
                (filename != null
                    ? MediaType.guessFromFileName(filename)
                    : MediaType.textPlain);
        sharedData.add(SharedBinary(data, filename, localMediaType));
        if (kDebugMode) {
          print(
            'share: loaded ${localMediaType.text}  "$filename" '
            'with ${data?.length} bytes',
          );
        }
      }
    } else if (text != null) {
      if (text.startsWith('mailto:')) {
        final mailto = Uri.parse(text);
        sharedData.add(SharedMailto(mailto));
      } else {
        sharedData.add(SharedText(text, mediaType, subject: shared['subject']));
      }
    }

    return sharedData;
  }
}
