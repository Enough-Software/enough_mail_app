import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/models.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Search input screen, currently used only for Cupertino
class SearchScreen extends StatefulWidget {
  final MessageSource messageSource;
  SearchScreen({Key? key, required this.messageSource}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    //TODO load previous search texts
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: CupertinoSearchTextField(
            controller: _controller,
            onSubmitted: _onSearchSubmitted,
          ),
        ),
        CupertinoDialogAction(
          child: Text(localizations.actionCancel),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }

  void _onSearchSubmitted(String text) {
    final search = MailSearch(text, SearchQueryType.allTextHeaders);
    final next = widget.messageSource.search(search);
    locator<NavigationService>().push(
      Routes.messageSource,
      arguments: next,
      replace: true,
    );
  }
}
