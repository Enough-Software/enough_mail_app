import 'dart:io';

import 'package:badges/badges.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuWithBadge extends StatelessWidget {
  final Widget? badgeContent;
  const MenuWithBadge({Key? key, this.badgeContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DensePlatformIconButton(
      icon: Badge(
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
      final localizations = AppLocalizations.of(context)!;
      return Text('\u2329 ${localizations.accountsTitle}');
    } else {
      return Icon(Icons.menu);
    }
  }
}
