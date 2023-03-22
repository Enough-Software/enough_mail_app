import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/l10n/extension.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/date_sectioned_message_source.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/models/swipe.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/util/string_helper.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_mail_app/widgets/cupertino_status_bar.dart';
import 'package:enough_mail_app/widgets/empty_message.dart';
import 'package:enough_mail_app/widgets/icon_text.dart';
import 'package:enough_mail_app/widgets/inherited_widgets.dart';
import 'package:enough_mail_app/widgets/mailbox_tree.dart';
import 'package:enough_mail_app/widgets/menu_with_badge.dart';
import 'package:enough_mail_app/widgets/message_overview_content.dart';
import 'package:enough_mail_app/widgets/message_stack.dart';
import 'package:enough_mail_app/widgets/search_text_field.dart';

import '../l10n/app_localizations.g.dart';
import '../locator.dart';

enum _Visualization { stack, list }

/// Loads a message source future
class AsyncMessageSourceScreen extends StatelessWidget {
  const AsyncMessageSourceScreen({
    Key? key,
    required this.messageSourceFuture,
  }) : super(key: key);
  final Future<MessageSource> messageSourceFuture;

  @override
  Widget build(BuildContext context) => FutureBuilder<MessageSource>(
        future: messageSourceFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data != null) {
            return MessageSourceScreen(messageSource: data);
          }
          if (snapshot.hasError) {
            return BasePage(
              title: context.text.errorTitle,
              content: Center(
                child: Text(context.text.detailsErrorDownloadInfo),
              ),
            );
          }
          return BasePage(
            title: context.text.homeLoadingMessageSourceTitle,
            content: Center(
              child: PlatformCircularProgressIndicator(),
            ),
          );
        },
      );
}

/// Displays a list of mails
class MessageSourceScreen extends StatefulWidget {
  final MessageSource messageSource;

  const MessageSourceScreen({
    Key? key,
    required this.messageSource,
  }) : super(key: key);

  @override
  State<MessageSourceScreen> createState() => _MessageSourceScreenState();
}

class _MessageSourceScreenState extends State<MessageSourceScreen>
    with TickerProviderStateMixin {
  late Future<void> _messageLoader;
  _Visualization _visualization = _Visualization.list;
  late DateSectionedMessageSource _sectionedMessageSource;
  bool _isInSelectionMode = false;
  List<Message> _selectedMessages = [];
  bool _isInSearchMode = false;
  bool _hasSearchInput = false;
  late TextEditingController _searchEditingController;
  bool _updateMessageSource = false;

  @override
  void initState() {
    super.initState();
    _searchEditingController = TextEditingController();
    _sectionedMessageSource = DateSectionedMessageSource(widget.messageSource);
    _sectionedMessageSource.addListener(_update);
    _messageLoader = initMessageSource();
  }

  Future<void> initMessageSource() {
    //print('${DateTime.now()}: initMessageSource()');
    return _sectionedMessageSource.init();
    //print('${DateTime.now()}: loaded ${_sectionedMessageSource.size} messages');
  }

  @override
  void dispose() {
    _searchEditingController.dispose();
    _sectionedMessageSource.removeListener(_update);
    _sectionedMessageSource.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _isInSearchMode = false;
      });
      return;
    }
    final search = MailSearch(query, SearchQueryType.allTextHeaders);
    final searchSource = _sectionedMessageSource.messageSource.search(search);
    locator<NavigationService>()
        .push(Routes.messageSource, arguments: searchSource);
    setState(() {
      _isInSearchMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('parent name: ${widget.messageSource.parentName}');
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final source = _sectionedMessageSource.messageSource;
    if (source is ErrorMessageSource) {
      return buildForLoadingError(context, localizations, source);
    }
    if (source == locator<MailService>().messageSource) {
      // listen to changes:
      _updateMessageSource = true;
      MailServiceWidget.of(context);
    } else if (_updateMessageSource) {
      _updateMessageSource = false;
      final state = MailServiceWidget.of(context);
      if (state != null) {
        final source = state.messageSource;
        if (source != null) {
          _sectionedMessageSource.removeListener(_update);
          _sectionedMessageSource = DateSectionedMessageSource(source);
          _sectionedMessageSource.addListener(_update);
          _messageLoader = initMessageSource();
        }
      }
    }
    final searchColor = theme.brightness == Brightness.light
        ? theme.colorScheme.onSecondary
        : theme.colorScheme.onPrimary;
    final appBarTitle = _isInSearchMode
        ? TextField(
            cursorColor: searchColor,
            controller: _searchEditingController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: localizations.homeSearchHint,
              hintStyle: TextStyle(
                color: searchColor.withAlpha(0xa0),
              ),
            ),
            autofocus: true,
            autocorrect: false,
            style: TextStyle(
              color: searchColor,
            ),
            onSubmitted: _search,
            onChanged: (text) {
              if (text.isNotEmpty != _hasSearchInput) {
                setState(() {
                  _hasSearchInput = text.isNotEmpty;
                });
              }
            },
          )
        : (PlatformInfo.isCupertino)
            ? Text(source.name ?? '')
            : Base.buildTitle(source.name ?? '', source.description ?? '');

    final appBarActions = [
      if (_isInSearchMode && _hasSearchInput)
        IconButton(
          icon: Icon(CommonPlatformIcons.clear),
          onPressed: () {
            _searchEditingController.text = '';
            setState(() {
              _hasSearchInput = false;
            });
          },
        ),

      if (source.supportsSearching && !PlatformInfo.isCupertino)
        PlatformIconButton(
          icon: Icon(_isInSearchMode ? Icons.arrow_back : Icons.search),
          onPressed: () {
            if (_isInSearchMode) {
              setState(() {
                _isInSearchMode = false;
              });
            } else {
              setState(() {
                _isInSearchMode = true;
              });
            }
          },
        ),
      if (PlatformInfo.isCupertino)
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            _isInSelectionMode
                ? localizations.actionCancel
                : localizations.actionEdit,
          ),
          onPressed: () {
            setState(() {
              _isInSelectionMode = !_isInSelectionMode;
            });
          },
        ),

      // if (!_isInSearchMode)
      //   PlatformPopupMenuButton<_Visualization>(
      //     onSelected: switchVisualization,
      //     itemBuilder: (context) => [
      //       _visualization == _Visualization.list
      //           ? PlatformPopupMenuItem<_Visualization>(
      //               value: _Visualization.stack,
      //               child: Text(localizations.homeActionsShowAsStack),
      //             )
      //           : PlatformPopupMenuItem<_Visualization>(
      //               value: _Visualization.list,
      //               child: Text(localizations.homeActionsShowAsList),
      //             ),
      //     ],
      //   ),
    ];
    final i18nService = locator<I18nService>();
    Widget? zeroPosWidget;
    if (_sectionedMessageSource.isInitialized && source.size == 0) {
      final emptyMessage = source.isSearch
          ? localizations.homeEmptySearchMessage
          : localizations.homeEmptyFolderMessage;
      zeroPosWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
        child: Text(emptyMessage),
      );
    } else if (source.supportsDeleteAll) {
      final iconService = locator<IconService>();
      final style = TextButton.styleFrom(primary: Colors.grey[600]);
      final textStyle = Theme.of(context).textTheme.button;
      zeroPosWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Wrap(
          children: [
            PlatformTextButtonIcon(
              style: style,
              icon: Icon(iconService.messageActionDelete),
              label: Text(localizations.homeDeleteAllAction, style: textStyle),
              onPressed: _deleteAllMessages,
            ),
            PlatformTextButtonIcon(
              style: style,
              icon: Icon(iconService.messageIsSeen),
              label:
                  Text(localizations.homeMarkAllSeenAction, style: textStyle),
              onPressed: () async {
                await source.markAllMessagesSeen(true);
              },
            ),
            PlatformTextButtonIcon(
              style: style,
              icon: Icon(iconService.messageIsNotSeen),
              label:
                  Text(localizations.homeMarkAllUnseenAction, style: textStyle),
              onPressed: () async {
                await source.markAllMessagesSeen(false);
              },
            ),
          ],
        ),
      );
    }
    final isSentFolder = source.isSent;
    final showSearchTextField =
        PlatformInfo.isCupertino && source.supportsSearching;
    return PlatformPageScaffold(
      bottomBar: _isInSelectionMode
          ? buildSelectionModeBottomBar(localizations)
          : PlatformInfo.isCupertino
              ? CupertinoStatusBar(
                  info: CupertinoStatusBar.createInfo(source.description),
                  rightAction: PlatformIconButton(
                    //TODO use CupertinoIcons.create once it's not buggy anymore
                    icon: const Icon(CupertinoIcons.pen),
                    onPressed: () => locator<NavigationService>().push(
                      Routes.mailCompose,
                      arguments: ComposeData(
                        null,
                        MessageBuilder(),
                        ComposeAction.newMessage,
                      ),
                    ),
                  ),
                )
              : null,
      material: (context, platform) => MaterialScaffoldData(
        drawer: const AppDrawer(),
        floatingActionButton: _visualization == _Visualization.stack
            ? null
            : FloatingActionButton(
                onPressed: () => locator<NavigationService>().push(
                  Routes.mailCompose,
                  arguments: ComposeData(
                    null,
                    MessageBuilder(),
                    ComposeAction.newMessage,
                  ),
                ),
                tooltip: localizations.homeFabTooltip,
                elevation: 2.0,
                child: const Icon(Icons.add),
              ),
      ),
      // cupertino: (context, platform) => CupertinoPageScaffoldData(),
      appBar: (_visualization == _Visualization.stack)
          ? PlatformAppBar(
              title: appBarTitle,
              trailingActions: appBarActions,
              leading: (locator<MailService>().hasAccountsWithErrors())
                  ? const MenuWithBadge()
                  : null,
            )
          : null,
      body: MessageSourceWidget(
        messageSource: source,
        child: FutureBuilder<void>(
          future: _messageLoader,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Center(
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: PlatformProgressIndicator(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            localizations.homeLoading(
                                source.name ?? source.description ?? ''),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              case ConnectionState.done:
                if (_visualization == _Visualization.stack) {
                  return WillPopScope(
                    onWillPop: () {
                      switchVisualization(_Visualization.list);
                      return Future.value(false);
                    },
                    child: MessageStack(messageSource: source),
                  );
                }
                final settings = locator<SettingsService>().settings;
                final swipeLeftToRightAction = settings.swipeLeftToRightAction;
                final swipeRightToLeftAction = settings.swipeRightToLeftAction;
                return WillPopScope(
                  onWillPop: () {
                    if (_isInSelectionMode) {
                      leaveSelectionMode();
                      return Future.value(false);
                    }
                    return Future.value(true);
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _sectionedMessageSource.refresh();
                    },
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        PlatformSliverAppBar(
                          stretch: true,
                          title: appBarTitle,
                          leading:
                              (locator<MailService>().hasAccountsWithErrors())
                                  ? MenuWithBadge(
                                      iOSText:
                                          '\u2329 ${localizations.accountsTitle}',
                                    )
                                  : null,
                          previousPageTitle:
                              source.parentName ?? localizations.accountsTitle,
                          floating: !_isInSearchMode,
                          pinned: _isInSearchMode,
                          actions: appBarActions,
                          cupertinoTransitionBetweenRoutes: true,
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              //print('building message item at $index');
                              if (showSearchTextField) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    child: CupertinoSearch(
                                      messageSource: source,
                                    ),
                                  );
                                }
                                index--;
                              }
                              if (zeroPosWidget != null) {
                                if (index == 0) {
                                  return zeroPosWidget;
                                }
                                index--;
                              }
                              return FutureBuilder<SectionElement>(
                                future:
                                    _sectionedMessageSource.getElementAt(index),
                                initialData: _sectionedMessageSource
                                    .getCachedElementAt(index),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return PlatformListTile(
                                      title: Row(
                                        children: const [
                                          Icon(Icons.replay),
                                          // TODO(RV): localize reload
                                          Text(' reload'),
                                        ],
                                      ),
                                      onTap: () {
                                        // TODO(RV): implement reload
                                        setState(() {});
                                      },
                                    );
                                  }
                                  final element = snapshot.data;

                                  if (element == null) {
                                    return const EmptyMessage();
                                  }
                                  final section = element.section;
                                  if (section != null) {
                                    final text = i18nService.formatDateRange(
                                        section.range, section.date);
                                    return GestureDetector(
                                      onLongPress: () async {
                                        _selectedMessages =
                                            await _sectionedMessageSource
                                                .getMessagesForSection(section);
                                        for (var m in _selectedMessages) {
                                          m.isSelected = true;
                                        }
                                        setState(() {
                                          _isInSelectionMode = true;
                                        });
                                      },
                                      onTap: !_isInSelectionMode
                                          ? null
                                          : () async {
                                              final sectionMessages =
                                                  await _sectionedMessageSource
                                                      .getMessagesForSection(
                                                          section);
                                              final doSelect = !sectionMessages
                                                  .first.isSelected;
                                              for (final msg
                                                  in sectionMessages) {
                                                if (doSelect) {
                                                  if (!msg.isSelected) {
                                                    msg.isSelected = true;
                                                    _selectedMessages.add(msg);
                                                  }
                                                } else {
                                                  if (msg.isSelected) {
                                                    msg.isSelected = false;
                                                    _selectedMessages
                                                        .remove(msg);
                                                  }
                                                }
                                              }
                                              setState(() {});
                                            },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16.0,
                                              right: 8.0,
                                              bottom: 4.0,
                                              top: 16.0,
                                            ),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                            ),
                                          ),
                                          const Divider()
                                        ],
                                      ),
                                    );
                                  }
                                  final message = element.message!;
                                  // print(
                                  //     '$index subject=${message.mimeMessage?.decodeSubject()}');
                                  return Dismissible(
                                    key: ValueKey(message),
                                    dismissThresholds: {
                                      DismissDirection.startToEnd:
                                          swipeLeftToRightAction
                                              .dismissThreshold,
                                      DismissDirection.endToStart:
                                          swipeRightToLeftAction
                                              .dismissThreshold,
                                    },
                                    background: Container(
                                      color: swipeLeftToRightAction
                                          .colorBackground,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              swipeLeftToRightAction
                                                  .name(localizations),
                                              style: TextStyle(
                                                  color: swipeLeftToRightAction
                                                      .colorForeground),
                                            ),
                                          ),
                                          Icon(swipeLeftToRightAction.icon,
                                              color: swipeLeftToRightAction
                                                  .colorIcon),
                                        ],
                                      ),
                                    ),
                                    secondaryBackground: Container(
                                      color: swipeRightToLeftAction
                                          .colorBackground,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            swipeRightToLeftAction.icon,
                                            color: swipeRightToLeftAction
                                                .colorIcon,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              swipeRightToLeftAction
                                                  .name(localizations),
                                              style: TextStyle(
                                                  color: swipeRightToLeftAction
                                                      .colorForeground),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: MessageOverview(
                                      message,
                                      _isInSelectionMode,
                                      onMessageTap,
                                      onMessageLongPress,
                                      isSentMessage: isSentFolder,
                                    ),
                                    confirmDismiss: (direction) {
                                      final swipeAction = direction ==
                                              DismissDirection.startToEnd
                                          ? swipeLeftToRightAction
                                          : swipeRightToLeftAction;
                                      fireSwipeAction(swipeAction, message);
                                      return Future.value(
                                        swipeAction.isMessageMoving,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            childCount: _sectionedMessageSource.size +
                                ((zeroPosWidget != null) ? 1 : 0) +
                                (showSearchTextField ? 1 : 0),
                            semanticIndexCallback:
                                (Widget widget, int localIndex) {
                              if (widget is MessageOverview) {
                                return widget.message.sourceIndex;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  Widget buildSelectionModeBottomBar(AppLocalizations localizations) {
    final source = _sectionedMessageSource.messageSource;
    final isTrash = source.isTrash;
    final isJunk = source.isJunk;
    final isAnyUnseen = _selectedMessages.any((m) => !m.isSeen);
    final isAnyUnflagged = _selectedMessages.any((m) => !m.isFlagged);
    final iconService = locator<IconService>();
    return PlatformBottomBar(
      cupertinoBlurBackground: true,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('${_selectedMessages.length}'),
            ),
            if (isAnyUnseen)
              PlatformIconButton(
                icon: Icon(iconService.messageIsNotSeen),
                onPressed: () => handleMultipleChoice(_MultipleChoice.seen),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageIsSeen),
                onPressed: () => handleMultipleChoice(_MultipleChoice.unseen),
              ),
            if (isAnyUnflagged)
              PlatformIconButton(
                icon: Icon(iconService.messageIsNotFlagged),
                onPressed: () => handleMultipleChoice(_MultipleChoice.flag),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageIsFlagged),
                onPressed: () => handleMultipleChoice(_MultipleChoice.unflag),
              ),
            if (isJunk)
              PlatformIconButton(
                icon: Icon(iconService.messageActionMoveFromJunkToInbox),
                onPressed: () => handleMultipleChoice(_MultipleChoice.inbox),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageActionMoveToJunk),
                onPressed: () => handleMultipleChoice(_MultipleChoice.junk),
              ),
            const Spacer(),
            if (isTrash)
              PlatformIconButton(
                icon: Icon(iconService.messageActionMoveToInbox),
                onPressed: () => handleMultipleChoice(_MultipleChoice.inbox),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageActionDelete),
                onPressed: () => handleMultipleChoice(_MultipleChoice.delete),
              ),
            PlatformIconButton(
              icon: const Icon(Icons.close),
              onPressed: leaveSelectionMode,
            ),
            PlatformPopupMenuButton<_MultipleChoice>(
              onSelected: handleMultipleChoice,
              itemBuilder: (context) => [
                PlatformPopupMenuItem(
                  value: _MultipleChoice.forwardAsAttachment,
                  child: IconText(
                    icon: Icon(iconService.messageActionForwardAsAttachment),
                    label: Text(localizations.messageActionForwardAsAttachment),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _MultipleChoice.forwardAttachments,
                  child: IconText(
                    icon: Icon(iconService.messageActionForwardAttachments),
                    label: Text(localizations.messagesActionForwardAttachments),
                  ),
                ),
                if (isTrash)
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.inbox,
                    child: IconText(
                      icon: Icon(iconService.messageActionMoveToInbox),
                      label: Text(localizations.messageActionMoveToInbox),
                    ),
                  )
                else
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.delete,
                    child: IconText(
                      icon: Icon(iconService.messageActionDelete),
                      label: Text(localizations.messageActionDelete),
                    ),
                  ),
                const PlatformPopupDivider(),
                if (isAnyUnseen)
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.seen,
                    child: IconText(
                      icon: Icon(iconService.messageIsSeen),
                      label: Text(localizations.messageActionMultipleMarkSeen),
                    ),
                  )
                else
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.unseen,
                    child: IconText(
                      icon: Icon(iconService.messageIsNotSeen),
                      label:
                          Text(localizations.messageActionMultipleMarkUnseen),
                    ),
                  ),
                if (isAnyUnflagged)
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.flag,
                    child: IconText(
                      icon: Icon(iconService.messageIsFlagged),
                      label:
                          Text(localizations.messageActionMultipleMarkFlagged),
                    ),
                  )
                else
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.unflag,
                    child: IconText(
                      icon: Icon(iconService.messageIsNotFlagged),
                      label: Text(
                          localizations.messageActionMultipleMarkUnflagged),
                    ),
                  ),
                if (source.supportsMessageFolders) ...[
                  const PlatformPopupDivider(),
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.move,
                    child: IconText(
                      icon: Icon(iconService.messageActionMove),
                      label: Text(localizations.messageActionMove),
                    ),
                  ),
                  if (isJunk)
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.inbox,
                      child: IconText(
                        icon:
                            Icon(iconService.messageActionMoveFromJunkToInbox),
                        label: Text(localizations.messageActionMarkAsNotJunk),
                      ),
                    )
                  else
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.junk,
                      child: IconText(
                        icon: Icon(iconService.messageActionMoveToJunk),
                        label: Text(localizations.messageActionMarkAsJunk),
                      ),
                    ),
                  if (source.isArchive)
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.inbox,
                      child: IconText(
                        icon: Icon(iconService.messageActionMoveToInbox),
                        label: Text(localizations.messageActionUnarchive),
                      ),
                    )
                  else
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.archive,
                      child: IconText(
                        icon: Icon(iconService.messageActionArchive),
                        label: Text(localizations.messageActionArchive),
                      ),
                    ),
                ], // folders are supported
                if (_selectedMessages.length == 1)
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.viewInSafeMode,
                    child: IconText(
                      icon: Icon(iconService.messageActionViewInSafeMode),
                      label: Text(localizations.messageActionViewInSafeMode),
                    ),
                  ),
                PlatformPopupMenuItem(
                  value: _MultipleChoice.addNotification,
                  child: IconText(
                    icon: Icon(iconService.messageActionAddNotification),
                    label: Text(
                      localizations.messageActionAddNotification,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void handleMultipleChoice(_MultipleChoice choice) async {
    final source = _sectionedMessageSource.messageSource;
    final localizations = locator<I18nService>().localizations;
    if (_selectedMessages.isEmpty) {
      locator<ScaffoldMessengerService>()
          .showTextSnackBar(localizations.multipleSelectionNeededInfo);
      return;
    }
    var endSelectionMode = true;
    switch (choice) {
      case _MultipleChoice.forwardAsAttachment:
        forwardAsAttachments();
        break;
      case _MultipleChoice.forwardAttachments:
        forwardAttachments();
        break;
      case _MultipleChoice.delete:
        final notification =
            localizations.multipleMovedToTrash(_selectedMessages.length);
        await source.deleteMessages(_selectedMessages, notification);
        break;
      case _MultipleChoice.inbox:
        final notification =
            localizations.multipleMovedToInbox(_selectedMessages.length);
        await source.moveMessagesToFlag(
            _selectedMessages, MailboxFlag.inbox, notification);
        break;
      case _MultipleChoice.seen:
        endSelectionMode = false;
        await source.markMessagesAsSeen(_selectedMessages, true);
        setState(() {});
        break;
      case _MultipleChoice.unseen:
        endSelectionMode = false;
        await source.markMessagesAsSeen(_selectedMessages, false);
        setState(() {});
        break;
      case _MultipleChoice.flag:
        endSelectionMode = false;
        await source.markMessagesAsFlagged(_selectedMessages, true);
        setState(() {});
        break;
      case _MultipleChoice.unflag:
        endSelectionMode = false;
        await source.markMessagesAsFlagged(_selectedMessages, false);
        setState(() {});
        break;
      case _MultipleChoice.move:
        endSelectionMode = false;
        move();
        break;
      case _MultipleChoice.junk:
        final notification =
            localizations.multipleMovedToJunk(_selectedMessages.length);
        await source.moveMessagesToFlag(
            _selectedMessages, MailboxFlag.junk, notification);
        break;
      case _MultipleChoice.archive:
        final notification =
            localizations.multipleMovedToArchive(_selectedMessages.length);
        await source.moveMessagesToFlag(
            _selectedMessages, MailboxFlag.archive, notification);
        break;
      case _MultipleChoice.viewInSafeMode:
        if (_selectedMessages.isNotEmpty) {
          locator<NavigationService>().push(Routes.mailDetails,
              arguments:
                  DisplayMessageArguments(_selectedMessages.first, true));
        }
        endSelectionMode = false;
        leaveSelectionMode();
        break;
      case _MultipleChoice.addNotification:
        endSelectionMode = false;
        final notificationService = locator<NotificationService>();
        for (final message in _selectedMessages) {
          notificationService.sendLocalNotificationForMailMessage(message);
        }
        leaveSelectionMode();
        break;
    }
    if (endSelectionMode) {
      setState(() {
        _isInSelectionMode = false;
      });
    }
  }

  void forwardAsAttachments() async {
    forwardAttachmentsLike(addMessageAttachment);
  }

  void forwardAttachments() {
    forwardAttachmentsLike(addAttachments);
  }

  void forwardAttachmentsLike(
      Future? Function(Message, MessageBuilder) loader) async {
    final builder = MessageBuilder();
    final fromAddresses = <MailAddress>[];
    final subjects = <String>[];
    final futures = <Future>[];
    for (final message in _selectedMessages) {
      message.isSelected = false;
      final mailClient = message.mailClient;
      final from = mailClient.account.fromAddress;
      if (!fromAddresses.contains(from)) {
        fromAddresses.add(from);
      }
      var mime = message.mimeMessage;
      final subject = mime.decodeSubject();
      if (subject?.isNotEmpty ?? false) {
        subjects.add(subject!.replaceAll('\r\n ', '').replaceAll('\n', ''));
      }
      final composeFuture = loader(message, builder);
      if (composeFuture != null) {
        futures.add(composeFuture);
      }
    }
    if (fromAddresses.length == 1) {
      builder.from = fromAddresses;
    }
    final lcs = StringHelper.largestCommonSequence(subjects);
    // print('lcs for $subjects is "$lcs"');
    if (lcs != null && lcs.length > 3) {
      builder.subject = MessageBuilder.createForwardSubject(lcs);
    }
    final composeFuture = futures.isEmpty ? null : Future.wait(futures);
    final composeData = ComposeData(
        _selectedMessages, builder, ComposeAction.forward,
        future: composeFuture);
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData, fade: true);
  }

  Future? addMessageAttachment(Message message, MessageBuilder builder) {
    final mime = message.mimeMessage;
    if (mime.mimeData == null) {
      return message.mailClient.fetchMessageContents(mime).then((value) {
        message.updateMime(value);
        builder.addMessagePart(value);
      });
    } else {
      builder.addMessagePart(mime);
    }
    return null;
  }

  Future? addAttachments(Message message, MessageBuilder builder) {
    final mailClient = message.mailClient;
    var mime = message.mimeMessage;
    Future? composeFuture;
    if (mime.mimeData == null) {
      composeFuture = mailClient.fetchMessageContents(mime).then((value) {
        message.updateMime(value);
        for (final attachment in message.attachments) {
          var part = value.getPart(attachment.fetchId);
          builder.addPart(mimePart: part);
        }
      });
    } else {
      final futures = <Future>[];
      for (final attachment in message.attachments) {
        final part = mime.getPart(attachment.fetchId);
        if (part != null) {
          builder.addPart(mimePart: part);
        } else {
          futures.add(mailClient
              .fetchMessagePart(mime, attachment.fetchId)
              .then((value) {
            builder.addPart(mimePart: value);
          }));
        }
        composeFuture = futures.isEmpty ? null : Future.wait(futures);
      }
    }
    return composeFuture;
  }

  void move() {
    final localizations = locator<I18nService>().localizations;
    var account = locator<MailService>().currentAccount!;
    if (account.isVirtual) {
      // check how many mailclient are involved in the current selection to either show the mailboxes of the unified account
      // or of the real account
      final mailClients = <MailClient>[];
      for (final message in _selectedMessages) {
        if (!mailClients.contains(message.mailClient)) {
          mailClients.add(message.mailClient);
        }
      }
      if (mailClients.length == 1) {
        // ok, all messages belong to one account:
        account =
            locator<MailService>().getAccountFor(mailClients.first.account)!;
      }
    }
    final mailbox = account.isVirtual
        ? null // //TODO set current mailbox, e.g.  current: widget.messageSource.currentMailbox,
        : _selectedMessages.first.mailClient.selectedMailbox;
    LocalizedDialogHelper.showWidgetDialog(
      context,
      SingleChildScrollView(
        child: MailboxTree(
          account: account,
          onSelected: moveTo,
          current: mailbox,
        ),
      ),
      title: localizations.multipleMoveTitle(_selectedMessages.length),
      defaultActions: DialogActions.cancel,
    );
  }

  void moveTo(Mailbox mailbox) async {
    setState(() {
      _isInSelectionMode = false;
    });
    locator<NavigationService>().pop(); // alert
    final source = _sectionedMessageSource.messageSource;
    final localizations = locator<I18nService>().localizations;
    final account = locator<MailService>().currentAccount!;
    if (account.isVirtual) {
      await source.moveMessagesToFlag(_selectedMessages, mailbox.flags.first,
          localizations.moveSuccess(mailbox.name));
    } else {
      await source.moveMessages(
          _selectedMessages, mailbox, localizations.moveSuccess(mailbox.name));
    }
  }

  void switchVisualization(_Visualization result) {
    setState(() {
      _visualization = result;
    });
  }

  void onMessageTap(Message message) async {
    if (_isInSelectionMode) {
      message.toggleSelected();
      if (message.isSelected) {
        _selectedMessages.add(message);
      } else {
        _selectedMessages.remove(message);
      }
      setState(() {});
    } else {
      if (message.mimeMessage.hasFlag(MessageFlags.draft)) {
        // continue to edit message:
        // first download message:
        final mime =
            await message.mailClient.fetchMessageContents(message.mimeMessage);
        //message.updateMime(mime);
        final builder = MessageBuilder.prepareFromDraft(mime);
        final data = ComposeData([message], builder, ComposeAction.newMessage);
        locator<NavigationService>().push(Routes.mailCompose, arguments: data);
      } else {
        // move to mail details:
        locator<NavigationService>()
            .push(Routes.mailDetails, arguments: message);
      }
    }
  }

  void onMessageLongPress(Message message) {
    message.isSelected = true;
    _selectedMessages = [message];
    setState(() {
      _isInSelectionMode = true;
    });
  }

  void leaveSelectionMode() {
    for (var m in _selectedMessages) {
      m.isSelected = false;
    }
    _selectedMessages = [];
    setState(() {
      _isInSelectionMode = false;
    });
  }

  Future<void> fireSwipeAction(SwipeAction action, Message message) {
    switch (action) {
      case SwipeAction.markRead:
        final isSeen = !message.isSeen;
        message.isSeen = isSeen;
        return _sectionedMessageSource.messageSource
            .markAsSeen(message, isSeen);
      case SwipeAction.archive:
        return _sectionedMessageSource.messageSource.archive(message);
      case SwipeAction.markJunk:
        return _sectionedMessageSource.messageSource.markAsJunk(message);
      case SwipeAction.delete:
        return _sectionedMessageSource.deleteMessage(message);
      case SwipeAction.flag:
        final isFlagged = !message.isFlagged;
        message.isFlagged = isFlagged;
        return _sectionedMessageSource.messageSource.storeMessageFlags(
          [message],
          [MessageFlags.flagged],
          action: isFlagged ? StoreAction.add : StoreAction.remove,
        );
    }
  }

  Widget buildForLoadingError(BuildContext context,
      AppLocalizations localizations, ErrorMessageSource errorSource) {
    final account = errorSource.account;
    return Base.buildAppChrome(
      context,
      title: localizations.errorTitle,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(localizations.accountLoadError(account.name)),
          ),
          PlatformTextButton(
            child: Text(localizations.accountLoadErrorEditAction),
            onPressed: () => locator<NavigationService>()
                .push(Routes.accountEdit, arguments: account),
          ),
          // this does not currently work, as no new login is done
          // PlatformTextButton(
          //   child: Text(localizations.detailsErrorDownloadRetry),
          //   onPressed: () async {
          //     final messageSource = await locator<MailService>()
          //         .getMessageSourceFor(account, switchToAccount: true);
          //     locator<NavigationService>().push(Routes.messageSource,
          //         arguments: messageSource, replace: true, fade: true);
          //   },
          // ),
        ],
      ),
    );
  }

  void _deleteAllMessages() async {
    final localizations = AppLocalizations.of(context)!;
    bool expunge = false;
    final confirmed = await LocalizedDialogHelper.showWidgetDialog(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.homeDeleteAllQuestion),
          CheckboxText(
            initialValue: false,
            onChanged: (value) => expunge = value,
            text: localizations.homeDeleteAllScrubOption,
          ),
        ],
      ),
      title: localizations.homeDeleteAllTitle,
      actions: [
        PlatformDialogActionText(
          text: localizations.actionCancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        PlatformDialogActionText(
          text: localizations.homeDeleteAllAction,
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed == true) {
      final results =
          await widget.messageSource.deleteAllMessages(expunge: expunge);
      Function()? undo;
      if (!expunge && results.any((result) => result.canUndo)) {
        undo = () async {
          final futures = <Future>[];
          for (final result in results) {
            if (result.canUndo) {
              futures.add(result.mailClient.undoDeleteMessages(result));
            }
          }
          if (futures.isNotEmpty) {
            await Future.wait(futures);
            await _sectionedMessageSource.refresh();
          }
        };
      }
      locator<ScaffoldMessengerService>()
          .showTextSnackBar(localizations.homeDeleteAllSuccess, undo: undo);
    }
  }
}

class CheckboxText extends StatefulWidget {
  const CheckboxText(
      {Key? key,
      required this.initialValue,
      required this.onChanged,
      required this.text})
      : super(key: key);
  final bool initialValue;
  final Function(bool value) onChanged;
  final String text;

  @override
  State<CheckboxText> createState() => _CheckboxTextState();
}

class _CheckboxTextState extends State<CheckboxText> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformCheckboxListTile(
      title: Text(widget.text),
      value: _value,
      onChanged: (value) {
        widget.onChanged(value == true);
        setState(() {
          _value = (value == true);
        });
      },
    );
  }
}

enum _MultipleChoice {
  forwardAsAttachment,
  forwardAttachments,
  delete,
  inbox,
  seen,
  unseen,
  flag,
  unflag,
  move,
  junk,
  archive,
  viewInSafeMode,
  addNotification,
}

class MessageOverview extends StatefulWidget {
  final Message message;
  final bool isInSelectionMode;
  final void Function(Message message) onTap;
  final void Function(Message message) onLongPress;
  final AnimationController? animationController;
  final bool isSentMessage;

  MessageOverview(
      this.message, this.isInSelectionMode, this.onTap, this.onLongPress,
      {this.animationController, required this.isSentMessage})
      : super(key: ValueKey(message.sourceIndex));

  @override
  State<MessageOverview> createState() => _MessageOverviewState();
}

class _MessageOverviewState extends State<MessageOverview> {
  _MessageOverviewState();

  @override
  void dispose() {
    widget.message.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  void initState() {
    widget.message.addListener(_update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (widget.animationController != null)
        ? SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: widget.animationController!,
              curve: Curves.easeOut,
            ),
            child: buildMessageOverview(),
          )
        : buildMessageOverview();
  }

  Widget buildMessageOverview() {
    return widget.isInSelectionMode
        ? PlatformCheckboxListTile(
            value: widget.message.isSelected,
            selected: widget.message.isSelected,
            title: MessageOverviewContent(
              message: widget.message,
              isSentMessage: widget.isSentMessage,
            ),
            onChanged: (value) => widget.onTap(widget.message),
          )
        : SelectablePlatformListTile(
            visualDensity: VisualDensity.compact,
            title: MessageOverviewContent(
              message: widget.message,
              isSentMessage: widget.isSentMessage,
            ),
            onTap: () => widget.onTap(widget.message),
            onLongPress: () => widget.onLongPress(widget.message),
          );
  }
}
