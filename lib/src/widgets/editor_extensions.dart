import 'package:community_material_icon/community_material_icon.dart';
import 'package:enough_ascii_art/enough_ascii_art.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../util/localized_dialog_helper.dart';

/// A button to open the art extension dialog.
class EditorArtExtensionButton extends ConsumerWidget {
  /// Creates a new [EditorArtExtensionButton].
  const EditorArtExtensionButton({super.key, required this.editorApi});

  /// The editor API.
  final HtmlEditorApi editorApi;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PlatformIconButton(
        icon: const Icon(CommunityMaterialIcons.format_font),
        onPressed: () => showArtExtensionDialog(ref, editorApi),
      );

  /// Shows the art extension dialog.
  static void showArtExtensionDialog(
    WidgetRef ref,
    HtmlEditorApi editorApi,
  ) {
    //final localizations = ref.text;
    LocalizedDialogHelper.showWidgetDialog(
      ref,
      _EditorArtExtensionWidget(editorApi: editorApi),
      defaultActions: DialogActions.cancel,
    );
  }
}

class _EditorArtExtensionWidget extends StatefulHookConsumerWidget {
  const _EditorArtExtensionWidget({required this.editorApi});
  final HtmlEditorApi editorApi;

  @override
  ConsumerState<_EditorArtExtensionWidget> createState() =>
      _EditorArtExtensionWidgetState();
}

class _EditorArtExtensionWidgetState
    extends ConsumerState<_EditorArtExtensionWidget> {
  final _inputController = TextEditingController();
  final _textsByUnicodeFont = <UnicodeFont, String>{};

  @override
  void initState() {
    super.initState();
    widget.editorApi.getSelectedText().then((value) {
      _updateTexts(value);
      _inputController.text = value ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ref.text;
    final captions = {
      UnicodeFont.serifBold: localizations.fontSerifBold,
      UnicodeFont.serifItalic: localizations.fontSerifItalic,
      UnicodeFont.serifBoldItalic: localizations.fontSerifBoldItalic,
      UnicodeFont.sans: localizations.fontSans,
      UnicodeFont.sansBold: localizations.fontSansBold,
      UnicodeFont.sansItalic: localizations.fontSansItalic,
      UnicodeFont.sansBoldItalic: localizations.fontSansBoldItalic,
      UnicodeFont.script: localizations.fontScript,
      UnicodeFont.scriptBold: localizations.fontScriptBold,
      UnicodeFont.fraktur: localizations.fontFraktur,
      UnicodeFont.frakturBold: localizations.fontFrakturBold,
      UnicodeFont.monospace: localizations.fontMonospace,
      // cSpell: disable
      UnicodeFont.fullwidth: localizations.fontFullwidth,
      UnicodeFont.doublestruck: localizations.fontDoublestruck,
      // cSpell: enable
      UnicodeFont.capitalized: localizations.fontCapitalized,
      UnicodeFont.circled: localizations.fontCircled,
      UnicodeFont.parenthesized: localizations.fontParenthesized,
      UnicodeFont.underlinedSingle: localizations.fontUnderlinedSingle,
      UnicodeFont.underlinedDouble: localizations.fontUnderlinedDouble,
      // cSpell: disable
      UnicodeFont.strikethroughSingle: localizations.fontStrikethroughSingle,
      // cSpell: enable
    };
    final captionStyle = Theme.of(context).textTheme.bodySmall;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedPlatformTextField(
              controller: _inputController,
              onChanged: _updateTexts,
              decoration: InputDecoration(
                labelText: localizations.editorArtInputLabel,
                hintText: localizations.editorArtInputHint,
              ),
            ),
          ),
          for (final unicodeFont in UnicodeFont.values)
            if (unicodeFont != UnicodeFont.normal) ...[
              Text(
                captions[unicodeFont] ?? '',
                style: captionStyle,
              ),
              PlatformTextButton(
                child: Text(
                  _textsByUnicodeFont[unicodeFont] ??
                      localizations.editorArtWaitingForInputHint,
                ),
                onPressed: () {
                  final text = _textsByUnicodeFont[unicodeFont];
                  if (text != null && text.isNotEmpty) {
                    widget.editorApi.insertText(text);
                  }
                  context.pop();
                },
              ),
              const Divider(),
            ],
        ],
      ),
    );
  }

  void _updateTexts(final String? input) {
    for (final unicodeFont in UnicodeFont.values) {
      if (unicodeFont != UnicodeFont.normal) {
        _textsByUnicodeFont[unicodeFont] =
            UnicodeFontConverter.encode(input ?? 'hello world', unicodeFont);
      }
    }
    setState(() {});
  }
}
