import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.g.dart';
import '../widgets/cupertino_status_bar.dart';

/// Allows to show snack bars
class ScaffoldMessengerService {
  /// Creates a new [ScaffoldMessengerService]
  ScaffoldMessengerService._();

  static final _instance = ScaffoldMessengerService._();

  /// The instance of the [ScaffoldMessengerService]
  static ScaffoldMessengerService get instance => _instance;

  /// The key of the scaffold messenger
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
    _statusBarState =
        _statusBarStates.isNotEmpty ? _statusBarStates.removeLast() : null;
  }

  SnackBar _buildTextSnackBar(
    AppLocalizations localizations,
    String text, {
    Function()? undo,
  }) =>
      SnackBar(
        content: Text(text),
        action: undo == null
            ? null
            : SnackBarAction(
                label: localizations.actionUndo,
                onPressed: undo,
              ),
      );

  void _showSnackBar(SnackBar snackBar) {
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void showTextSnackBar(
    AppLocalizations localizations,
    String text, {
    Function()? undo,
  }) {
    if (PlatformInfo.isCupertino) {
      final state = _statusBarState;
      if (state != null) {
        state.showTextStatus(text, undo: undo);
      } else {
        _showSnackBar(_buildTextSnackBar(localizations, text, undo: undo));
      }
    } else {
      _showSnackBar(_buildTextSnackBar(localizations, text, undo: undo));
    }
  }
}
