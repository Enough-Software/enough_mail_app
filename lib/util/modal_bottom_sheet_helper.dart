import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../screens/base.dart';

/// Helps to show a modal bottom sheet
class ModelBottomSheetHelper {
  ModelBottomSheetHelper._();

  /// Shows a modal bottom sheet
  static Future<T?> showModalBottomSheet<T>(
    BuildContext context,
    String title,
    Widget child, {
    List<Widget>? appBarActions,
    bool useScrollView = true,
  }) async {
    appBarActions ??= [
      DensePlatformIconButton(
        icon: Icon(CommonPlatformIcons.ok),
        onPressed: () => context.pop(true),
      ),
    ];
    final bottomSheetContent = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: BasePage(
          title: title,
          includeDrawer: false,
          appBarActions: appBarActions,
          content: useScrollView
              ? SingleChildScrollView(
                  child: SafeArea(
                    child: child,
                  ),
                )
              : SafeArea(child: child),
        ),
      ),
    );

    return PlatformInfo.isCupertino
        ? await showCupertinoModalBottomSheet<T>(
            context: context,
            builder: (context) => bottomSheetContent,
            elevation: 8,
            expand: true,
            isDismissible: true,
          )
        : await showMaterialModalBottomSheet<T>(
            context: context,
            builder: (context) => bottomSheetContent,
            elevation: 8,
            expand: true,
            backgroundColor: Colors.transparent,
          );
  }
}
