import 'dart:io';

import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/widgets/cupertino_status_bar.dart';
import 'package:flutter/material.dart';

class ScaffoldMessengerService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _statusBarStates = <CupertinoStatusBarState>[];
  CupertinoStatusBarState? _statusBarState;
  set statusBarState(CupertinoStatusBarState state) {
    final current = _statusBarState;
    if (current != null) {
      _statusBarStates.add(current);
    }
    _statusBarState = state;
  }

  void popStatusBarState() {
    if (_statusBarStates.isNotEmpty) {
      _statusBarState = _statusBarStates.removeLast();
    } else {
      _statusBarState = null;
    }
  }

  SnackBar _buildTextSnackBar(String text, {Function()? undo}) {
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
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void showTextSnackBar(String text, {Function()? undo}) {
    if (Platform.isIOS || Platform.isMacOS) {
      final state = _statusBarState;
      if (state != null) {
        state.showTextStatus(text, undo: undo);
      } else {
        _showSnackBar(_buildTextSnackBar(text, undo: undo));
      }
    } else {
      _showSnackBar(_buildTextSnackBar(text, undo: undo));
    }
  }
}
