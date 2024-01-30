import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/menu_with_badge.dart';

/// Provides a basic page layout with an app bar and a drawer.
class BasePage extends ConsumerWidget {
  /// Creates a new [BasePage].
  const BasePage({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.floatingActionButton,
    this.appBarActions,
    this.appBar,
    this.drawer,
    this.bottom,
    this.includeDrawer = true,
  });

  /// The title of the page.
  final String? title;

  /// The subtitle of the page.
  final String? subtitle;

  /// The content of the page.
  final Widget? content;

  /// The floating action button of the page.
  final FloatingActionButton? floatingActionButton;

  /// The actions of the app bar.
  final List<Widget>? appBarActions;

  /// The app bar.
  final PlatformAppBar? appBar;

  /// The drawer.
  final Widget? drawer;

  /// The bottom widget.
  final Widget? bottom;

  /// Whether to include the drawer.
  final bool includeDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PlatformAppBar? buildAppBar() {
      final title = this.title;

      if (title == null && subtitle == null && appBarActions == null) {
        return null;
      }
      final floatingActionButton = this.floatingActionButton;

      return PlatformAppBar(
        material: (context, platform) => MaterialAppBarData(
          elevation: 0,
        ),
        cupertino: (context, platform) => CupertinoNavigationBarData(
          transitionBetweenRoutes: false,
          trailing: floatingActionButton == null
              ? null
              : CupertinoButton(
                  onPressed: floatingActionButton.onPressed,
                  child: floatingActionButton.child ?? const SizedBox.shrink(),
                ),
        ),
        leading: (includeDrawer && ref.watch(hasAccountWithErrorProvider))
            ? const MenuWithBadge()
            : null,
        title: (title == null && subtitle == null)
            ? null
            : BaseTitle(
                title: title ?? '',
                subtitle: subtitle,
              ),
        automaticallyImplyLeading: true,
        trailingActions: appBarActions ?? [],
      );
    }

    return PlatformPageScaffold(
      appBar: buildAppBar(),
      body: content,
      bottomBar: bottom,
      material: (context, platform) => MaterialScaffoldData(
        drawer: drawer ?? (includeDrawer ? const AppDrawer() : null),
        floatingActionButton: floatingActionButton,
        // bottomNavBar: bottom,
      ),
    );
  }
}

/// Renders a title consisting of a title and an optional subtitle.
class BaseTitle extends StatelessWidget {
  /// Creates a new [BaseTitle].
  const BaseTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  /// The title of the app bar.
  final String title;

  /// The subtitle of the app bar.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return subtitle == null
        ? Text(title, overflow: TextOverflow.fade)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, overflow: TextOverflow.fade),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
  }
}

class SliverSingleChildHeaderDelegate extends SliverPersistentHeaderDelegate {
  SliverSingleChildHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.child,
    this.elevation,
    this.background,
  });

  final double maxHeight;
  final double minHeight;
  final double? elevation;
  final Widget child;
  final Widget? background;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Material(
        elevation: elevation ?? 0,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: maxHeight),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
                child: background ?? const SizedBox.shrink(),
              ),
              child,
            ],
          ),
        ),
      );

  @override
  double get maxExtent => kToolbarHeight + maxHeight;

  @override
  double get minExtent => kToolbarHeight + minHeight;

  @override
  bool shouldRebuild(SliverSingleChildHeaderDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight ||
      minHeight != oldDelegate.minHeight ||
      child != oldDelegate.child;
}

class CustomApBarSliverDelegate extends SliverPersistentHeaderDelegate {
  CustomApBarSliverDelegate({
    this.title,
    this.child,
    this.maxHeight = 350,
    this.background,
    this.minHeight = 0,
  });
  final Widget? child;
  final Widget? title;
  final Widget? background;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final appBarSize = maxExtent - shrinkOffset;
    final proportion = 2 - (maxExtent / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: maxHeight),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: background ?? const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(opacity: percent, child: child),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
