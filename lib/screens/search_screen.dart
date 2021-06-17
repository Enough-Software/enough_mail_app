import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/models.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
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
    final iconSize = 20.0;
    return Base.buildAppChrome(
      context,
      title: null,
      content: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: widget.messageSource,
                      child: CupertinoTextField(
                        padding: EdgeInsetsDirectional.fromSTEB(3.8, 8, 5, 8),
                        controller: _controller,
                        onSubmitted: _onSearchSubmitted,
                        autofocus: true,
                        prefix: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(6, 0, 0, 5),
                          child: Icon(
                            CupertinoIcons.search,
                            size: iconSize,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        placeholder: localizations.homeSearchHint,
                        placeholderStyle:
                            TextStyle(color: CupertinoColors.secondaryLabel),
                        suffix: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 2),
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: iconSize,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        suffixMode: OverlayVisibilityMode.editing,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: CupertinoColors.tertiarySystemFill,
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(localizations.actionCancel),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                )
              ],
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: CupertinoSearchTextField(
            //           placeholder: localizations.homeSearchHint,
            //         ),
            //       ),
            //     ),
            //     GestureDetector(
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Text(localizations.actionCancel),
            //       ),
            //       onTap: () => Navigator.of(context).pop(),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
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
