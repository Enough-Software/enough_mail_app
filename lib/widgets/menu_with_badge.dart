import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class MenuWithBadge extends StatelessWidget {
  final Widget badgeContent;
  const MenuWithBadge({Key key, this.badgeContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(badgeContent: badgeContent, child: Icon(Icons.menu)),
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}
