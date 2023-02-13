import 'package:enough_mail_app/models/swipe.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'base.dart';

class SettingsSwipeScreen extends StatelessWidget {
  const SettingsSwipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = locator<SettingsService>().settings;
    final leftToRightAction = settings.swipeLeftToRightAction;
    final rightToLeftAction = settings.swipeRightToLeftAction;

    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.swipeSettingTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.swipeSettingLeftToRightLabel,
                    style: theme.textTheme.caption),
                _SwipeSetting(
                  swipeAction: leftToRightAction,
                  isLeftToRight: true,
                ),
                const Divider(),
                Text(localizations.swipeSettingRightToLeftLabel,
                    style: theme.textTheme.caption),
                _SwipeSetting(
                  swipeAction: rightToLeftAction,
                  isLeftToRight: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeSetting extends StatefulWidget {
  final bool isLeftToRight;
  final SwipeAction swipeAction;

  const _SwipeSetting(
      {Key? key, required this.swipeAction, required this.isLeftToRight})
      : super(key: key);

  @override
  _SwipeSettingState createState() => _SwipeSettingState();
}

class _SwipeSettingState extends State<_SwipeSetting> {
  late SwipeAction _currentAction;

  @override
  void initState() {
    super.initState();
    _currentAction = widget.swipeAction;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        PlatformTextButton(
          onPressed: _onPressed,
          child: _SwipeWidget(
            swipeAction: _currentAction,
          ),
        ),
        PlatformTextButtonIcon(
          onPressed: _onPressed,
          icon: const Icon(Icons.edit),
          label: ButtonText(localizations.swipeSettingChangeAction),
        ),
      ],
    );
  }

  void _onPressed() async {
    final action = await selectSwipe(_currentAction);
    if (action != null) {
      setState(() {
        _currentAction = action;
      });
      final service = locator<SettingsService>();
      if (widget.isLeftToRight) {
        service.settings =
            service.settings.copyWith(swipeLeftToRightAction: action);
      } else {
        service.settings =
            service.settings.copyWith(swipeRightToLeftAction: action);
      }
      await service.save();
    }
  }

  Future<SwipeAction?> selectSwipe(SwipeAction current) async {
    final localizations = AppLocalizations.of(context);

    final action = await LocalizedDialogHelper.showWidgetDialog(
      context,
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
        child: GridView.count(
          crossAxisCount: 2,
          // shrinkWrap: true,
          children: SwipeAction.values
              .map(
                (action) => PlatformTextButton(
                  child: Stack(
                    children: [
                      _SwipeWidget(
                        swipeAction: action,
                        isSmall: true,
                      ),
                      if (action == current)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    locator<NavigationService>().pop(action);
                  },
                ),
              )
              .toList(),
        ),
      ),
      title: widget.isLeftToRight
          ? localizations!.swipeSettingLeftToRightLabel
          : localizations!.swipeSettingRightToLeftLabel,
      defaultActions: DialogActions.cancel,
    );
    if (action == false) {
      return null;
    }
    return action;
  }
}

class _SwipeWidget extends StatelessWidget {
  final SwipeAction swipeAction;
  final bool isSmall;
  const _SwipeWidget(
      {Key? key, required this.swipeAction, this.isSmall = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: swipeAction.colorBackground,
          width: 128,
          height: 128,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Icon(
                    swipeAction.icon,
                    color: swipeAction.colorIcon,
                  ),
                ),
                Text(
                  swipeAction.name(localizations),
                  style: TextStyle(
                    color: swipeAction.colorForeground,
                    fontSize: isSmall ? 10.0 : 12.0,
                  ),
                  // overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
