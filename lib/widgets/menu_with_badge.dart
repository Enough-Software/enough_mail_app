import 'package:badges/badges.dart' as badges;
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuWithBadge extends StatelessWidget {
  const MenuWithBadge({
    super.key,
    this.badgeContent,
    this.iOSText,
  });
  final Widget? badgeContent;
  final String? iOSText;

  @override
  Widget build(BuildContext context) => DensePlatformIconButton(
        icon: badges.Badge(
          badgeContent: badgeContent,
          child: _buildIndicator(context),
        ),
        onPressed: () {
          if (PlatformInfo.isCupertino) {
            // go back
            context.pop();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
      );

  Widget _buildIndicator(BuildContext context) {
    if (PlatformInfo.isCupertino) {
      final iOSText = this.iOSText;

      return iOSText != null ? Text(iOSText) : const Icon(CupertinoIcons.back);
    } else {
      return const Icon(Icons.menu);
    }
  }
}
