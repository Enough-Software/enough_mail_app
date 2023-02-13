import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuWithBadge extends StatelessWidget {
  const MenuWithBadge({
    Key? key,
    this.badgeContent,
    this.iOSText,
  }) : super(key: key);
  final Widget? badgeContent;
  final String? iOSText;

  @override
  Widget build(BuildContext context) {
    return DensePlatformIconButton(
      icon: badges.Badge(
        badgeContent: badgeContent,
        child: _buildIndicator(context),
      ),
      onPressed: () {
        if (Platform.isIOS) {
          // go back
          locator<NavigationService>().pop();
        } else {
          Scaffold.of(context).openDrawer();
        }
      },
    );
  }

  Widget _buildIndicator(BuildContext context) {
    if (Platform.isIOS) {
      final iOSText = this.iOSText;
      if (iOSText != null) {
        return Text(iOSText);
      } else {
        return const Icon(CupertinoIcons.back);
      }
    } else {
      return const Icon(Icons.menu);
    }
  }
}
