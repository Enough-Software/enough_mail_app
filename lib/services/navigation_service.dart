import 'package:enough_mail_app/routes.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

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
      return navigatorKey.currentState.pushReplacement(route);
    } else {
      return navigatorKey.currentState.push(route);
    }
  }

  void popUntil(String routeName) {
    navigatorKey.currentState.popUntil(ModalRoute.withName(routeName));
  }

  void pop([Object result]) {
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
