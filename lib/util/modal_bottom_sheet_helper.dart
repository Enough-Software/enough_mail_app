import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ModelBottomSheetHelper {
  ModelBottomSheetHelper._();

  static Future<bool> showModalBottomSheet(
      BuildContext context, String title, Widget child,
      {List<Widget>? appBarActions, bool useScrollView = true}) async {
    appBarActions ??= [
      DensePlatformIconButton(
        icon: Icon(CommonPlatformIcons.ok),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ];
    final bottomSheetContent = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Base.buildAppChrome(
          context,
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

    dynamic result;
    if (PlatformInfo.isCupertino) {
      result = await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => bottomSheetContent,
        elevation: 8.0,
        expand: true,
        isDismissible: true,
      );
    } else {
      result = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => bottomSheetContent,
        elevation: 8.0,
        expand: true,
        backgroundColor: Colors.transparent,
      );
    }
    return (result == true);
  }
}
