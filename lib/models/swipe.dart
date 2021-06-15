import 'package:enough_mail_app/services/icon_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../locator.dart';

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
        return Colors.blue[200]!;
      case SwipeAction.archive:
        return Colors.amber[200]!;
      case SwipeAction.markJunk:
        return Colors.red[200]!;
      case SwipeAction.delete:
        return Colors.red[600]!;
      case SwipeAction.flag:
        return Colors.lime[600]!;
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
        return Colors.blue[900]!;
      case SwipeAction.archive:
        return Colors.amber[900]!;
      case SwipeAction.markJunk:
        return Colors.red[900]!;
      case SwipeAction.delete:
        return Colors.white;
      case SwipeAction.flag:
        return Colors.lime[900]!;
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

  IconData get icon {
    final iconService = locator<IconService>();
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
