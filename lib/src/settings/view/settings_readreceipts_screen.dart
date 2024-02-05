import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../localization/extension.dart';
import '../../screens/base.dart';
import '../model.dart';
import '../provider.dart';

class SettingsReadReceiptsScreen extends HookConsumerWidget {
  const SettingsReadReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readReceiptDisplaySetting = ref.watch(
      settingsProvider.select(
        (value) => value.readReceiptDisplaySetting,
      ),
    );
    final theme = Theme.of(context);
    final localizations = ref.text;

    void onReadReceiptDisplaySettingChanged(ReadReceiptDisplaySetting? value) =>
        _onReadReceiptDisplaySettingChanged(value, ref);

    return BasePage(
      title: localizations.settingsReadReceipts,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.readReceiptsSettingsIntroduction,
                  style: theme.textTheme.bodySmall,
                ),
                PlatformRadioListTile<ReadReceiptDisplaySetting>(
                  value: ReadReceiptDisplaySetting.always,
                  groupValue: readReceiptDisplaySetting,
                  onChanged: onReadReceiptDisplaySettingChanged,
                  title: Text(localizations.readReceiptOptionAlways),
                ),
                PlatformRadioListTile<ReadReceiptDisplaySetting>(
                  value: ReadReceiptDisplaySetting.never,
                  groupValue: readReceiptDisplaySetting,
                  onChanged: onReadReceiptDisplaySettingChanged,
                  title: Text(localizations.readReceiptOptionNever),
                ),
                // PlatformRadioListTile<ReadReceiptDisplaySetting>(
                //   value: ReadReceiptDisplaySetting.forContacts,
                //   groupValue: readReceiptDisplaySetting,
                //   onChanged: onReadReceiptDisplaySettingChanged,
                //   title: Text(localizations.readReceiptOptionForContacts),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onReadReceiptDisplaySettingChanged(
    ReadReceiptDisplaySetting? value,
    WidgetRef ref,
  ) async {
    if (value == null) return;
    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).update(
          settings.copyWith(readReceiptDisplaySetting: value),
        );
  }
}
