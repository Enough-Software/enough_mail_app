import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/extension.dart';
import '../../screens/base.dart';
import '../model.dart';
import '../provider.dart';

class SettingsReplyScreen extends ConsumerWidget {
  const SettingsReplyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.text;
    String getFormatPreferenceName(ReplyFormatPreference preference) {
      switch (preference) {
        case ReplyFormatPreference.alwaysHtml:
          return localizations.replySettingsFormatHtml;
        case ReplyFormatPreference.sameFormat:
          return localizations.replySettingsFormatSameAsOriginal;
        case ReplyFormatPreference.alwaysPlainText:
          return localizations.replySettingsFormatPlainText;
      }
    }

    final currentPreference = ref.watch(
      settingsProvider.select((value) => value.replyFormatPreference),
    );

    return Base.buildAppChrome(
      context,
      title: localizations.replySettingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.replySettingsIntro),
                for (final preference in ReplyFormatPreference.values)
                  PlatformRadioListTile<ReplyFormatPreference>(
                    value: preference,
                    groupValue: currentPreference,
                    onChanged: (value) async {
                      if (value != null) {
                        final settings = ref.read(settingsProvider);
                        await ref.read(settingsProvider.notifier).update(
                              settings.copyWith(replyFormatPreference: value),
                            );
                      }
                    },
                    title: Text(
                      getFormatPreferenceName(preference),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
