import 'package:enough_mail_app/widgets/text_with_links.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';

class Legalese extends StatelessWidget {
  static const String urlPrivacyPolicy =
      'https://www.enough.de/privacypolicy/maily-pp.html';
  static const String urlTermsAndConditions =
      'https://github.com/Enough-Software/enough_mail_app/blob/main/LICENSE';
  const Legalese({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final legaleseUsage = localizations.legaleseUsage;
    final privacyPolicy = localizations.legalesePrivacyPolicy;
    final termsAndConditions = localizations.legaleseTermsAndConditions;
    final ppIndex = legaleseUsage.indexOf('[PP]');
    final tcIndex = legaleseUsage.indexOf('[TC]');
    final legaleseParts = [
      TextLink(legaleseUsage.substring(0, ppIndex)),
      TextLink(privacyPolicy, urlPrivacyPolicy),
      TextLink(legaleseUsage.substring(ppIndex + '[PP]'.length, tcIndex)),
      TextLink(termsAndConditions, urlTermsAndConditions),
      TextLink(legaleseUsage.substring(tcIndex + '[TC]'.length)),
    ];
    return TextWithNamedLinks(
      parts: legaleseParts,
    );
  }
}
