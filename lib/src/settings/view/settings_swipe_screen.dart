import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../localization/extension.dart';
import '../../models/swipe.dart';
import '../../screens/base.dart';
import '../../util/localized_dialog_helper.dart';
import '../provider.dart';

class SettingsSwipeScreen extends ConsumerWidget {
  const SettingsSwipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final leftToRightAction = settings.swipeLeftToRightAction;
    final rightToLeftAction = settings.swipeRightToLeftAction;

    final theme = Theme.of(context);
    final localizations = ref.text;

    return BasePage(
      title: localizations.swipeSettingTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.swipeSettingLeftToRightLabel,
                  style: theme.textTheme.bodySmall,
                ),
                _SwipeSetting(
                  swipeAction: leftToRightAction,
                  isLeftToRight: true,
                ),
                const Divider(),
                Text(
                  localizations.swipeSettingRightToLeftLabel,
                  style: theme.textTheme.bodySmall,
                ),
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

class _SwipeSetting extends HookConsumerWidget {
  const _SwipeSetting({
    required this.swipeAction,
    required this.isLeftToRight,
  });

  final bool isLeftToRight;
  final SwipeAction swipeAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final swipeActionState = useState(swipeAction);

    Future<SwipeAction?> selectSwipe(SwipeAction current) async {
      final action = await LocalizedDialogHelper.showWidgetDialog(
        ref,
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
                      context.pop(action);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        title: isLeftToRight
            ? localizations.swipeSettingLeftToRightLabel
            : localizations.swipeSettingRightToLeftLabel,
        defaultActions: DialogActions.cancel,
      );
      if (action == false) {
        return null;
      }

      return action;
    }

    Future<void> onPressed() async {
      final action = await selectSwipe(swipeActionState.value);
      if (action != null) {
        swipeActionState.value = action;
        final settings = ref.read(settingsProvider);
        final newSettings = isLeftToRight
            ? settings.copyWith(swipeLeftToRightAction: action)
            : settings.copyWith(swipeRightToLeftAction: action);
        await ref.read(settingsProvider.notifier).update(
              newSettings,
            );
      }
    }

    return Row(
      children: [
        PlatformTextButton(
          onPressed: onPressed,
          child: _SwipeWidget(
            swipeAction: swipeActionState.value,
          ),
        ),
        PlatformTextButtonIcon(
          onPressed: onPressed,
          icon: const Icon(Icons.edit),
          label: Text(localizations.swipeSettingChangeAction),
        ),
      ],
    );
  }
}

class _SwipeWidget extends ConsumerWidget {
  const _SwipeWidget({required this.swipeAction, this.isSmall = false});
  final SwipeAction swipeAction;
  final bool isSmall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: swipeAction.colorBackground,
          width: 128,
          height: 128,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
