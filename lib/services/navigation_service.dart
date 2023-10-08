import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../routes.dart';

class NavigationService {
  GlobalKey<NavigatorState> get navigatorKey => Routes.navigatorKey;

  BuildContext? get currentContext => navigatorKey.currentContext;
  String? get currentRouteName => _currentRouteName;
  String? _currentRouteName;

  Future<T?> push<T>(
    String routeName, {
    Object? arguments,
    bool replace = false,
    bool fade = false,
    bool clear = false,
    bool containsModals = false,
  }) {
    _currentRouteName = routeName;
    final page = AppRouter.generatePage(routeName, arguments);
    final state = navigatorKey.currentState;
    if (state == null) {
      return Future.value();
    }
    Route<T> route;
    if (containsModals) {
      route = MaterialWithModalsPageRoute<T>(builder: (_) => page);
    } else if (fade && !PlatformInfo.isCupertino) {
      route = FadeRoute<T>(page: page);
    } else {
      route = PlatformInfo.isCupertino
          ? CupertinoPageRoute<T>(builder: (_) => page)
          : MaterialPageRoute<T>(builder: (_) => page);
    }
    if (clear) {
      state.popUntil((route) => false);
    }

    return replace ? state.pushReplacement(route) : state.push(route);
  }

  // void replace(String oldRouteName, String newRouteName, {Object arguments}) {
  //   final page = AppRouter.generatePage(newRouteName, arguments);
  //   final newRoute = MaterialPageRoute(builder: (context) => page);
  //   final oldRoute = history.getRoute(oldRouteName);
  //   navigatorKey.currentState.replace(oldRoute: oldRoute, newRoute: newRoute);
  // }

  // void replaceBelow(String anchorRouteName, String newRouteName,
  //     {Object arguments}) {
  //   final page = AppRouter.generatePage(newRouteName, arguments);
  //   final newRoute = MaterialPageRoute(builder: (context) => page);
  //   final anchorRoute = history.getRoute(anchorRouteName);
  //   navigatorKey.currentState
  //       .replaceRouteBelow(anchorRoute: anchorRoute, newRoute: newRoute);
  // }

  void popUntil(String routeName) {
    final state = navigatorKey.currentState;
    if (state == null) {
      return;
    }
    // history.popUntil(routeName);
    state.popUntil(ModalRoute.withName(routeName));
    _currentRouteName = routeName;
  }

  void pop<T>([T? result]) {
    final state = navigatorKey.currentState;
    if (state == null) {
      return;
    }
    // history.pop();
    state.pop<T>(result);
    _currentRouteName = null;
  }
}

class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

  final Widget page;
}
