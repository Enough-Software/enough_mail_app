import 'package:flutter/material.dart';

import '../localization/app_localizations.g.dart';
import '../settings/theme/icon_service.dart';

enum SwipeAction {
  markRead,
  archive,
  markJunk,
  delete,
  flag,
  //move (later)
}

extension SwipeExtension on SwipeAction {
  Color get colorBackground {
    switch (this) {
      case SwipeAction.markRead:
        return Colors.blue[200] ?? Colors.lightBlue;
      case SwipeAction.archive:
        return Colors.amber[200] ?? Colors.amber;
      case SwipeAction.markJunk:
        return Colors.red[200] ?? Colors.orangeAccent;
      case SwipeAction.delete:
        return Colors.red[600] ?? Colors.red;
      case SwipeAction.flag:
        return Colors.lime[600] ?? Colors.lime;
    }
  }

  Color get colorForeground {
    switch (this) {
      case SwipeAction.markRead:
        return Colors.black;
      case SwipeAction.archive:
        return Colors.black;
      case SwipeAction.markJunk:
        return Colors.black;
      case SwipeAction.delete:
        return Colors.white;
      case SwipeAction.flag:
        return Colors.black;
    }
  }

  Color get colorIcon {
    switch (this) {
      case SwipeAction.markRead:
        return Colors.blue[900] ?? Colors.blue;
      case SwipeAction.archive:
        return Colors.amber[900] ?? Colors.amber;
      case SwipeAction.markJunk:
        return Colors.red[900] ?? Colors.red;
      case SwipeAction.delete:
        return Colors.white;
      case SwipeAction.flag:
        return Colors.lime[900] ?? Colors.lime;
    }
  }

  Brightness get brightness {
    switch (this) {
      case SwipeAction.markRead:
        return Brightness.light;
      case SwipeAction.archive:
        return Brightness.light;
      case SwipeAction.markJunk:
        return Brightness.light;
      case SwipeAction.delete:
        return Brightness.dark;
      case SwipeAction.flag:
        return Brightness.light;
    }
  }

  /// Icon of the action
  IconData get icon {
    final iconService = IconService.instance;
    switch (this) {
      case SwipeAction.markRead:
        return iconService.messageIsNotSeen;
      case SwipeAction.archive:
        return iconService.messageActionArchive;
      case SwipeAction.markJunk:
        return iconService.messageActionMoveToJunk;
      case SwipeAction.delete:
        return iconService.messageActionDelete;
      case SwipeAction.flag:
        return iconService.messageIsNotFlagged;
    }
  }

  /// localized name of the action
  String name(AppLocalizations localizations) {
    switch (this) {
      case SwipeAction.markRead:
        return localizations.swipeActionToggleRead;
      case SwipeAction.archive:
        return localizations.swipeActionArchive;
      case SwipeAction.markJunk:
        return localizations.swipeActionMarkJunk;
      case SwipeAction.delete:
        return localizations.swipeActionDelete;
      case SwipeAction.flag:
        return localizations.swipeActionFlag;
    }
  }

  /// The threshold in percent when the action is triggered
  double get dismissThreshold {
    switch (this) {
      case SwipeAction.markRead:
        return 0.3;
      case SwipeAction.archive:
        return 0.5;
      case SwipeAction.markJunk:
        return 0.5;
      case SwipeAction.delete:
        return 0.5;
      case SwipeAction.flag:
        return 0.3;
    }
  }

  /// Does this action move the message away from the current list?
  bool get isMessageMoving {
    switch (this) {
      case SwipeAction.markRead:
        return false;
      case SwipeAction.archive:
        return true;
      case SwipeAction.markJunk:
        return true;
      case SwipeAction.delete:
        return true;
      case SwipeAction.flag:
        return false;
    }
  }
}
