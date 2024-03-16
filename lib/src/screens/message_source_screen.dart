import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/provider.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../logger.dart';
import '../mail/model.dart';
import '../models/compose_data.dart';
import '../models/date_sectioned_message_source.dart';
import '../models/message.dart';
import '../models/message_source.dart';
import '../models/swipe.dart';
import '../notification/service.dart';
import '../routes/routes.dart';
import '../scaffold_messenger/service.dart';
import '../settings/provider.dart';
import '../settings/theme/icon_service.dart';
import '../util/localized_dialog_helper.dart';
import '../util/string_helper.dart';
import '../widgets/search_text_field.dart';
import '../widgets/widgets.dart';
import 'base.dart';

enum _Visualization { stack, list }

/// Displays a list of mails
class MessageSourceScreen extends ConsumerStatefulWidget {
  /// Creates a new [MessageSourceScreen]
  const MessageSourceScreen({
    super.key,
    required this.messageSource,
  });

  /// The source for the shown messages
  final MessageSource messageSource;

  @override
  ConsumerState<MessageSourceScreen> createState() =>
      _MessageSourceScreenState();
}

class _MessageSourceScreenState extends ConsumerState<MessageSourceScreen>
    with TickerProviderStateMixin {
  late Future<void> _messageLoader;
  _Visualization _visualization = _Visualization.list;
  late DateSectionedMessageSource _sectionedMessageSource;
  bool _isInSelectionMode = false;
  List<Message> _selectedMessages = [];
  bool _isInSearchMode = false;
  bool _hasSearchInput = false;
  late TextEditingController _searchEditingController;

  @override
  void initState() {
    super.initState();
    _searchEditingController = TextEditingController();
    _sectionedMessageSource = DateSectionedMessageSource(
      widget.messageSource,
      firstDayOfWeek: ref.firstDayOfWeek,
    );
    _sectionedMessageSource.addListener(_update);
    _messageLoader = _initMessageSource();
  }

  Future<void> _initMessageSource() => _sectionedMessageSource.init();

  @override
  void dispose() {
    _searchEditingController.dispose();
    _sectionedMessageSource
      ..removeListener(_update)
      ..dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  void _search(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _isInSearchMode = false;
      });

      return;
    }
    final search = MailSearch(trimmedQuery, SearchQueryType.allTextHeaders);
    final searchSource =
        _sectionedMessageSource.messageSource.search(ref.text, search);
    context.pushNamed(
      Routes.messageSource,
      pathParameters: {
        Routes.pathParameterEmail: widget.messageSource.account.email,
      },
      extra: searchSource,
    );
    setState(() {
      _isInSearchMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('parent name: ${widget.messageSource.parentName}');
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final localizations = ref.text;
    final source = _sectionedMessageSource.messageSource;
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
            ? Text(source.localizedName(localizations, settings))
            : BaseTitle(
                title: source.localizedName(localizations, settings),
                subtitle: source.description,
              );

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
      final iconService = IconService.instance;
      final style = TextButton.styleFrom(foregroundColor: Colors.grey[600]);
      final textStyle = Theme.of(context).textTheme.labelLarge;
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
    final hasAccountWithError = ref.watch(hasAccountWithErrorProvider);

    return PlatformPageScaffold(
      bottomBar: _isInSelectionMode
          ? buildSelectionModeBottomBar(localizations)
          : PlatformInfo.isCupertino
              ? CupertinoStatusBar(
                  info: CupertinoStatusBar.createInfo(source.description),
                  rightAction: PlatformIconButton(
                    // TODO(RV): use CupertinoIcons.create once available
                    icon: const Icon(CupertinoIcons.pen),
                    onPressed: () => context.pushNamed(
                      Routes.mailCompose,
                      extra: ComposeData(
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
            : const NewMailMessageButton(),
      ),
      // cupertino: (context, platform) => CupertinoPageScaffoldData(),
      appBar: (_visualization == _Visualization.stack)
          ? PlatformAppBar(
              title: appBarTitle,
              trailingActions: appBarActions,
              leading: hasAccountWithError ? const MenuWithBadge() : null,
            )
          : null,
      body: FutureBuilder<void>(
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
                      padding: EdgeInsets.all(8),
                      child: PlatformProgressIndicator(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          localizations.homeLoading(
                            source.name ?? source.description ?? '',
                          ),
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
              final settings = ref.read(settingsProvider);
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
                      EnoughPlatformSliverAppBar(
                        stretch: true,
                        title: appBarTitle,
                        leading: hasAccountWithError
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
                      if (showSearchTextField)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: CupertinoSearch(
                              messageSource: source,
                            ),
                          ),
                        ),
                      if (zeroPosWidget != null)
                        SliverToBoxAdapter(
                          child: zeroPosWidget,
                        ),
                      SliverFixedExtentList.builder(
                        itemExtent: 52,
                        itemBuilder: (context, index) =>
                            FutureBuilder<SectionElement>(
                          future: _sectionedMessageSource.getElementAt(index),
                          initialData:
                              _sectionedMessageSource.getCachedElementAt(index),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return PlatformListTile(
                                title: const Row(
                                  children: [
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
                              final text = ref.getDateRangeName(
                                section.range,
                              );

                              return GestureDetector(
                                onLongPress: () async {
                                  _selectedMessages =
                                      await _sectionedMessageSource
                                          .getMessagesForSection(section);
                                  for (final m in _selectedMessages) {
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
                                          section,
                                        );
                                        final doSelect =
                                            !sectionMessages.first.isSelected;
                                        for (final msg in sectionMessages) {
                                          if (doSelect) {
                                            if (!msg.isSelected) {
                                              msg.isSelected = true;
                                              _selectedMessages.add(msg);
                                            }
                                          } else {
                                            if (msg.isSelected) {
                                              msg.isSelected = false;
                                              _selectedMessages.remove(msg);
                                            }
                                          }
                                        }
                                        setState(() {});
                                      },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 8,
                                        bottom: 4,
                                        top: 16,
                                      ),
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            }
                            final message = element.message;

                            if (message == null) {
                              return const SizedBox.shrink();
                            }

                            return Dismissible(
                              key: ValueKey(message),
                              dismissThresholds: {
                                DismissDirection.startToEnd:
                                    swipeLeftToRightAction.dismissThreshold,
                                DismissDirection.endToStart:
                                    swipeRightToLeftAction.dismissThreshold,
                              },
                              background: Container(
                                color: swipeLeftToRightAction.colorBackground,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                alignment: AlignmentDirectional.centerStart,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        swipeLeftToRightAction
                                            .name(localizations),
                                        style: TextStyle(
                                          color: swipeLeftToRightAction
                                              .colorForeground,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      swipeLeftToRightAction.icon,
                                      color: swipeLeftToRightAction.colorIcon,
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: swipeRightToLeftAction.colorBackground,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                alignment: AlignmentDirectional.centerEnd,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      swipeRightToLeftAction.icon,
                                      color: swipeRightToLeftAction.colorIcon,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        swipeRightToLeftAction
                                            .name(localizations),
                                        style: TextStyle(
                                          color: swipeRightToLeftAction
                                              .colorForeground,
                                        ),
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
                                final swipeAction =
                                    direction == DismissDirection.startToEnd
                                        ? swipeLeftToRightAction
                                        : swipeRightToLeftAction;
                                fireSwipeAction(
                                  localizations,
                                  swipeAction,
                                  message,
                                );

                                return Future.value(
                                  swipeAction.isMessageMoving,
                                );
                              },
                            );
                          },
                        ),
                        itemCount: _sectionedMessageSource.size,
                      ),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  Widget buildSelectionModeBottomBar(AppLocalizations localizations) {
    final source = _sectionedMessageSource.messageSource;
    final isTrash = source.isTrash;
    final isJunk = source.isJunk;
    final isAnyUnseen = _selectedMessages.any((m) => !m.isSeen);
    final isAnyUnflagged = _selectedMessages.any((m) => !m.isFlagged);
    final iconService = IconService.instance;

    return PlatformBottomBar(
      cupertinoBlurBackground: true,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${_selectedMessages.length}'),
            ),
            if (isAnyUnseen)
              PlatformIconButton(
                icon: Icon(iconService.messageIsNotSeen),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.seen),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageIsSeen),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.unseen),
              ),
            if (isAnyUnflagged)
              PlatformIconButton(
                icon: Icon(iconService.messageIsNotFlagged),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.flag),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageIsFlagged),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.unflag),
              ),
            if (isJunk)
              PlatformIconButton(
                icon: Icon(iconService.messageActionMoveFromJunkToInbox),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.inbox),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageActionMoveToJunk),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.junk),
              ),
            const Spacer(),
            if (isTrash)
              PlatformIconButton(
                icon: Icon(iconService.messageActionMoveToInbox),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.inbox),
              )
            else
              PlatformIconButton(
                icon: Icon(iconService.messageActionDelete),
                onPressed: () => _handleMultipleChoice(_MultipleChoice.delete),
              ),
            PlatformIconButton(
              icon: const Icon(Icons.close),
              onPressed: leaveSelectionMode,
            ),
            PlatformPopupMenuButton<_MultipleChoice>(
              onSelected: _handleMultipleChoice,
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
                        localizations.messageActionMultipleMarkUnflagged,
                      ),
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

  Future<void> _handleMultipleChoice(_MultipleChoice choice) async {
    final source = _sectionedMessageSource.messageSource;
    final localizations = ref.text;
    if (_selectedMessages.isEmpty) {
      ScaffoldMessengerService.instance.showTextSnackBar(
        localizations,
        localizations.multipleSelectionNeededInfo,
      );

      return;
    }

    try {
      final endSelectionMode =
          await _handleChoice(choice, source, localizations);
      if (endSelectionMode) {
        setState(() {
          _isInSelectionMode = false;
        });
      }
    } catch (e, s) {
      logger.e(
        'Unable to handle multiple choice $choice: $e',
        error: e,
        stackTrace: s,
      );

      ScaffoldMessengerService.instance.showTextSnackBar(
        localizations,
        localizations.multipleSelectionActionFailed(e.toString()),
      );
    }
  }

  Future<bool> _handleChoice(
    _MultipleChoice choice,
    MessageSource source,
    AppLocalizations localizations,
  ) async {
    var endSelectionMode = true;
    switch (choice) {
      case _MultipleChoice.forwardAsAttachment:
        await forwardAsAttachments();
        break;
      case _MultipleChoice.forwardAttachments:
        forwardAttachments();
        break;
      case _MultipleChoice.delete:
        final notification =
            localizations.multipleMovedToTrash(_selectedMessages.length);
        await source.deleteMessages(
          localizations,
          _selectedMessages,
          notification,
        );
        break;
      case _MultipleChoice.inbox:
        final notification =
            localizations.multipleMovedToInbox(_selectedMessages.length);
        await source.moveMessagesToFlag(
          localizations,
          _selectedMessages,
          MailboxFlag.inbox,
          notification,
        );
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
          localizations,
          _selectedMessages,
          MailboxFlag.junk,
          notification,
        );
        break;
      case _MultipleChoice.archive:
        final notification =
            localizations.multipleMovedToArchive(_selectedMessages.length);
        await source.moveMessagesToFlag(
          localizations,
          _selectedMessages,
          MailboxFlag.archive,
          notification,
        );
        break;
      case _MultipleChoice.viewInSafeMode:
        if (_selectedMessages.isNotEmpty && context.mounted) {
          unawaited(context.pushNamed(
            Routes.mailDetails,
            extra: _selectedMessages.first,
            queryParameters: {
              Routes.queryParameterBlockExternalContent: 'true',
            },
          ));
        }
        endSelectionMode = false;
        leaveSelectionMode();
        break;
      case _MultipleChoice.addNotification:
        endSelectionMode = false;
        final notificationService = NotificationService.instance;
        for (final message in _selectedMessages) {
          await notificationService
              .sendLocalNotificationForMailMessage(message);
        }
        leaveSelectionMode();
        break;
    }

    return endSelectionMode;
  }

  Future<void> forwardAsAttachments() async {
    await forwardAttachmentsLike(addMessageAttachment);
  }

  void forwardAttachments() {
    forwardAttachmentsLike(addAttachments);
  }

  Future<void> forwardAttachmentsLike(
    Future? Function(Message, MessageBuilder) loader,
  ) async {
    final builder = MessageBuilder();
    final fromAddresses = <MailAddress>[];
    final subjects = <String>[];
    final futures = <Future>[];
    for (final message in _selectedMessages) {
      message.isSelected = false;
      final mailClient = message.source.getMimeSource(message)?.mailClient;
      if (mailClient == null) {
        continue;
      }
      final from = mailClient.account.fromAddress;
      if (!fromAddresses.contains(from)) {
        fromAddresses.add(from);
      }
      final mime = message.mimeMessage;
      final subject = mime.decodeSubject();
      if (subject != null && subject.isNotEmpty) {
        subjects.add(subject.replaceAll('\r\n ', '').replaceAll('\n', ''));
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
      _selectedMessages,
      builder,
      ComposeAction.forward,
      future: composeFuture,
    );
    unawaited(context.pushNamed(Routes.mailCompose, extra: composeData));
  }

  Future<void> addMessageAttachment(Message message, MessageBuilder builder) {
    final mime = message.mimeMessage;
    if (mime.mimeData == null) {
      return message.source.fetchMessageContents(message).then((value) {
        builder.addMessagePart(value);
      });
    } else {
      builder.addMessagePart(mime);
    }

    return Future.value();
  }

  Future? addAttachments(Message message, MessageBuilder builder) {
    final mime = message.mimeMessage;
    Future? composeFuture;
    if (mime.mimeData == null) {
      composeFuture =
          message.source.fetchMessageContents(message).then((value) {
        for (final attachment in message.attachments) {
          final part = value.getPart(attachment.fetchId);
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
          futures.add(message.source
              .fetchMessagePart(message, fetchId: attachment.fetchId)
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
    final localizations = ref.text;
    var account = widget.messageSource.account;
    if (account.isVirtual) {
      // check how many mail-clients are involved in the current selection
      // to either show the mailboxes of the unified account
      // or of the real account
      final mailClients = <MailClient>[];
      for (final message in _selectedMessages) {
        final mailClient = message.source.getMimeSource(message)?.mailClient;
        if (mailClient != null && !mailClients.contains(mailClient)) {
          mailClients.add(mailClient);
        }
      }
      if (mailClients.length == 1) {
        // ok, all messages belong to one account:
        final singleAccount = ref.read(
          findRealAccountByEmailProvider(
            email: mailClients.first.account.email,
          ),
        );
        if (singleAccount != null) {
          account = singleAccount;
        }
      }
    }

    LocalizedDialogHelper.showWidgetDialog(
      ref,
      SingleChildScrollView(
        child: MailboxTree(
          account: account,
          onSelected: moveTo,
        ),
      ),
      title: localizations.multipleMoveTitle(_selectedMessages.length),
      defaultActions: DialogActions.cancel,
    );
  }

  Future<void> moveTo(Mailbox mailbox) async {
    setState(() {
      _isInSelectionMode = false;
    });
    context.pop(); // alert
    final source = _sectionedMessageSource.messageSource;
    final localizations = ref.text;
    final account = widget.messageSource.account;
    if (account.isVirtual) {
      await source.moveMessagesToFlag(
        localizations,
        _selectedMessages,
        mailbox.flags.first,
        localizations.moveSuccess(mailbox.name),
      );
    } else {
      await source.moveMessages(
        localizations,
        _selectedMessages,
        mailbox,
        localizations.moveSuccess(mailbox.name),
      );
    }
  }

  void switchVisualization(_Visualization result) {
    setState(() {
      _visualization = result;
    });
  }

  Future<void> onMessageTap(Message message) async {
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
        final mime = await message.source.fetchMessageContents(message);
        //message.updateMime(mime);
        final builder = MessageBuilder.prepareFromDraft(mime);
        final data = ComposeData([message], builder, ComposeAction.newMessage);
        if (mounted) {
          unawaited(context.pushNamed(Routes.mailCompose, extra: data));
        }
      } else {
        // move to mail details:
        if (mounted) {
          unawaited(context.pushNamed(Routes.mailDetails, extra: message));
        }
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
    for (final m in _selectedMessages) {
      m.isSelected = false;
    }
    _selectedMessages = [];
    setState(() {
      _isInSelectionMode = false;
    });
  }

  Future<void> fireSwipeAction(
    AppLocalizations localizations,
    SwipeAction action,
    Message message,
  ) {
    switch (action) {
      case SwipeAction.markRead:
        final isSeen = !message.isSeen;
        message.isSeen = isSeen;
        return _sectionedMessageSource.messageSource
            .markAsSeen(message, isSeen);
      case SwipeAction.archive:
        return _sectionedMessageSource.messageSource
            .archive(localizations, message);
      case SwipeAction.markJunk:
        return _sectionedMessageSource.messageSource
            .markAsJunk(localizations, message);
      case SwipeAction.delete:
        return _sectionedMessageSource.deleteMessage(localizations, message);
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

  Future<void> _deleteAllMessages() async {
    final localizations = ref.text;
    final firstMessage = widget.messageSource.cache.first;
    var expunge =
        firstMessage?.mimeMessage.hasFlag(MessageFlags.deleted) ?? false;
    final confirmed = await LocalizedDialogHelper.showWidgetDialog(
      ref,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.homeDeleteAllQuestion),
          CheckboxText(
            initialValue: expunge,
            onChanged: (value) => expunge = value,
            text: localizations.homeDeleteAllScrubOption,
          ),
        ],
      ),
      title: localizations.homeDeleteAllTitle,
      actions: [
        PlatformDialogActionText(
          text: localizations.actionCancel,
          onPressed: () => context.pop(false),
        ),
        PlatformDialogActionText(
          text: localizations.homeDeleteAllAction,
          isDestructiveAction: true,
          onPressed: () => context.pop(true),
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
      ScaffoldMessengerService.instance.showTextSnackBar(
        localizations,
        localizations.homeDeleteAllSuccess,
        undo: undo,
      );
    }
  }
}

class CheckboxText extends StatefulWidget {
  const CheckboxText({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.text,
  });

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
  Widget build(BuildContext context) => PlatformCheckboxListTile(
        title: Text(widget.text),
        value: _value,
        onChanged: (value) {
          widget.onChanged(value ?? false);
          setState(() {
            _value = value ?? false;
          });
        },
      );
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
  MessageOverview(
    this.message,
    this.isInSelectionMode,
    this.onTap,
    this.onLongPress, {
    this.animationController,
    required this.isSentMessage,
  }) : super(key: ValueKey(message.sourceIndex));
  final Message message;
  final bool isInSelectionMode;
  final void Function(Message message) onTap;
  final void Function(Message message) onLongPress;
  final AnimationController? animationController;
  final bool isSentMessage;

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
  Widget build(BuildContext context) => (widget.animationController != null)
      ? SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: widget.animationController!,
            curve: Curves.easeOut,
          ),
          child: buildMessageOverview(),
        )
      : buildMessageOverview();

  Widget buildMessageOverview() => widget.isInSelectionMode
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
