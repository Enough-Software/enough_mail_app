import 'package:enough_mail_app/routes.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  // final history = _NavigationHistory();

  Future<dynamic> push(String routeName,
      {Object arguments,
      bool replace = false,
      bool fade = false,
      bool clear = false}) {
    final page = AppRouter.generatePage(routeName, arguments);
    Route route;
    if (fade) {
      route = FadeRoute(page: page);
    } else {
      route = MaterialPageRoute(builder: (context) => page);
    }
    if (clear) {
      navigatorKey.currentState.popUntil((route) => false);
    }
    if (replace) {
      // history.replace(routeName, route);
      return navigatorKey.currentState.pushReplacement(route);
    } else {
      // history.push(routeName, route);
      return navigatorKey.currentState.push(route);
    }
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
    // history.popUntil(routeName);
    navigatorKey.currentState.popUntil(ModalRoute.withName(routeName));
  }

  void pop([Object result]) {
    // history.pop();
    navigatorKey.currentState.pop(result);
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({@required this.page})
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
}
