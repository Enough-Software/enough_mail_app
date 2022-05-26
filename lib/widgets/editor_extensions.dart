import 'package:community_material_icon/community_material_icon.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import 'package:enough_ascii_art/enough_ascii_art.dart';

import '../locator.dart';

class EditorArtExtensionButton extends StatelessWidget {
  const EditorArtExtensionButton({Key? key, required this.editorApi})
      : super(key: key);
  final HtmlEditorApi editorApi;

  @override
  Widget build(BuildContext context) {
    return PlatformIconButton(
      icon: const Icon(CommunityMaterialIcons.format_font),
      onPressed: () => showArtExtensionDialog(context, editorApi),
    );
  }

  static void showArtExtensionDialog(
      BuildContext context, HtmlEditorApi editorApi) {
    //final localizations = AppLocalizations.of(context);
    LocalizedDialogHelper.showWidgetDialog(
      context,
      EditorArtExtensionWidget(editorApi: editorApi),
      defaultActions: DialogActions.cancel,
    );
  }
}

class EditorArtExtensionWidget extends StatefulWidget {
  final HtmlEditorApi editorApi;
  const EditorArtExtensionWidget({Key? key, required this.editorApi})
      : super(key: key);

  @override
  State<EditorArtExtensionWidget> createState() =>
      _EditorArtExtensionWidgetState();
}

class _EditorArtExtensionWidgetState extends State<EditorArtExtensionWidget> {
  final _inputController = TextEditingController();
  final _textsByUnicodeFont = <UnicodeFont, String>{};

  @override
  void initState() {
    super.initState();
    widget.editorApi.getSelectedText().then((value) {
      _updateTexts(value);
      _inputController.text = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
      UnicodeFont.fullwidth: localizations.fontFullwidth,
      UnicodeFont.doublestruck: localizations.fontDoublestruck,
      UnicodeFont.capitalized: localizations.fontCapitalized,
      UnicodeFont.circled: localizations.fontCircled,
      UnicodeFont.parenthesized: localizations.fontParenthesized,
      UnicodeFont.underlinedSingle: localizations.fontUnderlinedSingle,
      UnicodeFont.underlinedDouble: localizations.fontUnderlinedDouble,
      UnicodeFont.strikethroughSingle: localizations.fontStrikethroughSingle,
    };
    final captionStyle = Theme.of(context).textTheme.caption;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: DecoratedPlatformTextField(
              controller: _inputController,
              onChanged: (value) => _updateTexts(value),
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
                child: ButtonText(_textsByUnicodeFont[unicodeFont] ??
                    localizations.editorArtWaitingForInputHint),
                onPressed: () {
                  final text = _textsByUnicodeFont[unicodeFont];
                  if (text != null && text.isNotEmpty) {
                    widget.editorApi.insertText(text);
                  }
                  final navService = locator<NavigationService>();
                  navService.pop();
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
            UnicodeFontConverter.encode(input!, unicodeFont);
      }
    }
    setState(() {});
  }
}
