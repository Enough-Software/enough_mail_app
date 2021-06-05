import 'dart:io';

import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/widgets/cupertino_status_bar.dart';
import 'package:flutter/material.dart';

class ScaffoldMessengerService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<CupertinoStatusBarState> statusBarKey =
      GlobalKey<CupertinoStatusBarState>();

  SnackBar _buildTextSnackBar(String text, {Function() undo}) {
    return SnackBar(
      content: Text(text),
      action: undo == null
          ? null
          : SnackBarAction(
              label: locator<I18nService>().localizations.actionUndo,
              onPressed: undo,
            ),
    );
  }

  void _showSnackBar(SnackBar snackBar) {
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  }

  void showTextSnackBar(String text, {Function() undo}) {
    if (Platform.isIOS) {
      statusBarKey.currentState?.showTextStatus(text, undo: undo);
    } else {
      _showSnackBar(_buildTextSnackBar(text, undo: undo));
    }
  }

  void showCupertinoPermanentStatus(String text) {
    if (Platform.isIOS) {
      statusBarKey.currentState?.showPermanentStatus(text);
    }
  }
}
