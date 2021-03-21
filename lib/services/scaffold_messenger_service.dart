import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:flutter/material.dart';

class ScaffoldMessengerService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  SnackBar buildTextSnackBar(String text, {Function() undo}) {
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

  void showSnackBar(SnackBar snackBar) {
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  }

  void showTextSnackBar(String text, {Function() undo}) {
    showSnackBar(buildTextSnackBar(text, undo: undo));
  }
}
