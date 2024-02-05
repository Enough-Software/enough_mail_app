import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../localization/extension.dart';
import '../../screens/base.dart';
import 'model.dart';
import 'provider.dart';

/// Allows to personalize the app settings
class SettingsScreen extends ConsumerWidget {
  /// Creates a new [SettingsScreen]
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiSettingElementsNotifier = ref.watch(
      settingsUiElementsProvider.notifier,
    );
    final settingEntries = uiSettingElementsNotifier.generate(ref);
    final localizations = ref.text;

    Widget buildEntry(UiSettingsElement entry) {
      if (entry.isDivider) return const Divider();
      final subtitle = entry.subtitle;
      final icon = entry.icon;

      return PlatformListTile(
        title: Text(entry.title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: icon != null ? Icon(icon) : null,
        onTap: entry.onTap,
      );
    }

    return BasePage(
      title: localizations.settingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: settingEntries.map(buildEntry).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
