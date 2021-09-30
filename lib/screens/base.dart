import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_mail_app/widgets/menu_with_badge.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
// import 'package:enough_style/enough_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../locator.dart';

class Base {
  static Widget buildAppChrome(
    BuildContext context, {
    required String? title,
    required Widget? content,
    FloatingActionButton? floatingActionButton,
    List<Widget>? appBarActions,
    PlatformAppBar? appBar,
    Widget? drawer,
    String? subtitle,
    Widget? bottom,
    bool includeDrawer = true,
  }) {
    appBar ??= (title == null && subtitle == null && appBarActions == null)
        ? null
        : buildAppBar(
            context,
            title,
            actions: appBarActions,
            subtitle: subtitle,
            floatingActionButton: floatingActionButton,
            includeDrawer: includeDrawer,
          );
    if (includeDrawer) {
      drawer ??= buildDrawer(context);
    }

    return PlatformPageScaffold(
      appBar: appBar,
      body: content,
      bottomBar: bottom,
      material: (context, platform) => MaterialScaffoldData(
        drawer: drawer,
        floatingActionButton: floatingActionButton,
        // bottomNavBar: bottom,
      ),
    );
  }

  static PlatformAppBar buildAppBar(
    BuildContext context,
    String? title, {
    List<Widget>? actions,
    String? subtitle,
    FloatingActionButton? floatingActionButton,
    bool includeDrawer = true,
  }) {
    return PlatformAppBar(
      material: (context, platform) => MaterialAppBarData(
        elevation: 0,
      ),
      cupertino: (context, platform) => CupertinoNavigationBarData(
        transitionBetweenRoutes: false,
        trailing: floatingActionButton == null
            ? null
            : CupertinoButton(
                child: floatingActionButton.child!,
                onPressed: floatingActionButton.onPressed,
              ),
      ),
      leading: (includeDrawer && locator<MailService>().hasAccountsWithErrors())
          ? MenuWithBadge()
          : null,
      title: buildTitle(title, subtitle),
      automaticallyImplyLeading: true,
      trailingActions: actions ?? [],
    );
  }

  static Widget? buildTitle(String? title, String? subtitle) {
    if (subtitle == null) {
      if (title == null) {
        return null;
      }
      return Text(
        title,
        overflow: TextOverflow.fade,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            overflow: TextOverflow.fade,
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    }
  }

  static Widget buildDrawer(BuildContext context) {
    return AppDrawer();
  }
}

class SliverSingleChildHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final double? elevation;
  final Widget child;
  final Widget? background;

  SliverSingleChildHeaderDelegate(
      {required this.maxHeight,
      required this.minHeight,
      required this.child,
      this.elevation,
      this.background});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: elevation ?? 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: maxHeight),
        child: Stack(
          children: [
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              top: 0,
              child: background!,
            ),
            child
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight + maxHeight;

  @override
  double get minExtent => kToolbarHeight + minHeight;

  @override
  bool shouldRebuild(SliverSingleChildHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class CustomApBarSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget? child;
  final Widget? title;
  final Widget? background;
  final double minHeight;
  final double maxHeight;

  CustomApBarSliverDelegate({
    this.title,
    this.child,
    this.maxHeight = 350,
    this.background,
    this.minHeight = 0,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = maxExtent - shrinkOffset;
    final proportion = 2 - (maxExtent / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: maxHeight),
      child: Stack(
        children: [
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            top: 0,
            child: background!,
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Opacity(opacity: percent, child: child),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              title: Opacity(opacity: 1 - percent, child: title),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration();

  @override
  double get minExtent => kToolbarHeight + minHeight;

  @override
  double get maxExtent => kToolbarHeight + maxHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
