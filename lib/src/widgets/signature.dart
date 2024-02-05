import 'dart:async';

import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../account/model.dart';
import '../account/provider.dart';
import '../localization/extension.dart';
import '../settings/provider.dart';
import '../settings/theme/icon_service.dart';
import '../util/modal_bottom_sheet_helper.dart';

class SignatureWidget extends HookConsumerWidget {
  const SignatureWidget({super.key, this.account});
  final RealAccount? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = this.account;
    final signatureState = useState<String?>(
      account?.getSignatureHtml(ref.text.localeName) ??
          ref.read(settingsProvider.notifier).getSignatureHtmlGlobal(),
    );
    final signature = signatureState.value;

    Future<void> showEditor() async {
      final localizations = ref.text;
      final iconService = IconService.instance;
      HtmlEditorApi? editorApi;

      final result = await ModelBottomSheetHelper.showModalBottomSheet<bool>(
        context,
        account?.name ?? localizations.signatureSettingsTitle,
        PackagedHtmlEditor(
          initialContent: signature ??
              ref.read(settingsProvider.notifier).getSignatureHtmlGlobal(),
          excludeDocumentLevelControls: true,
          onCreated: (api) => editorApi = api,
        ),
        appBarActions: [
          if (signature != null)
            DensePlatformIconButton(
              icon: Icon(iconService.messageActionDelete),
              onPressed: () async {
                signatureState.value = null;

                context.pop(false);
                if (account != null) {
                  account.signatureHtml = null;
                  unawaited(ref.read(realAccountsProvider.notifier).save());
                } else {
                  final settings = ref.read(settingsProvider);
                  final notifier = ref.read(settingsProvider.notifier);
                  signatureState.value = notifier.getSignatureHtmlGlobal();
                  await notifier.update(
                    settings.withoutSignatures(),
                  );
                }
              },
            ),
          DensePlatformIconButton(
            icon: Icon(CommonPlatformIcons.ok),
            onPressed: () => context.pop(true),
          ),
        ],
      );
      final usedEditorApi = editorApi;
      if ((result ?? false) && usedEditorApi != null) {
        final newSignature = await usedEditorApi.getText();
        signatureState.value = newSignature;
        if (account == null) {
          final settings = ref.read(settingsProvider);
          await ref.read(settingsProvider.notifier).update(
                settings.copyWith(signatureHtml: newSignature),
              );
        } else {
          account.signatureHtml = newSignature;
          unawaited(ref.read(realAccountsProvider.notifier).save());
        }
      }
    }

    if (signature == null) {
      return PlatformListTile(
        leading: const Icon(Icons.add),
        title: Text(
          ref.text.signatureSettingsAddForAccount(account?.name ?? ''),
        ),
        onTap: showEditor,
      );
    }

    return Stack(
      children: [
        HtmlWidget(
          signature,
          onTapUrl: (url) => launcher.launchUrl(Uri.parse(url)),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PlatformIconButton(
            icon: const Icon(Icons.edit),
            onPressed: showEditor,
          ),
        ),
      ],
    );
  }
}
