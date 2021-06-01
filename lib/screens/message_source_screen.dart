import 'dart:async';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/events/unified_messagesource_changed_event.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/date_sectioned_message_source.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/models/swipe.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/util/string_helper.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_mail_app/widgets/mailbox_tree.dart';
import 'package:enough_mail_app/widgets/menu_with_badge.dart';
import 'package:enough_mail_app/widgets/message_overview_content.dart';
import 'package:enough_mail_app/widgets/message_stack.dart';
import 'package:enough_mail_app/widgets/status_bar.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
// import 'package:enough_style/enough_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../locator.dart';

enum _Visualization { stack, list }

/// Displays a list of mails
class MessageSourceScreen extends StatefulWidget {
  final MessageSource messageSource;

  MessageSourceScreen(this.messageSource);

  @override
  _MessageSourceScreenState createState() => _MessageSourceScreenState();
}

class _MessageSourceScreenState extends State<MessageSourceScreen>
    with TickerProviderStateMixin {
  Future<void> _messageLoader;
  _Visualization _visualization = _Visualization.list;
  DateSectionedMessageSource _sectionedMessageSource;
  bool isInSelectionMode = false;
  List<Message> selectedMessages = [];
  bool isInSearchMode = false;
  bool hasSearchInput = false;
  TextEditingController searchEditingController;
  StreamSubscription eventsSubscription;

  @override
  void initState() {
    super.initState();
    searchEditingController = TextEditingController();
    _sectionedMessageSource = DateSectionedMessageSource(widget.messageSource);
    _sectionedMessageSource.addListener(_update);
    _messageLoader = initMessageSource();
    eventsSubscription = AppEventBus.eventBus
        .on<UnifiedMessageSourceChangedEvent>()
        .listen((event) {
      setState(() {
        _sectionedMessageSource.removeListener(_update);
        _sectionedMessageSource.dispose();
        _sectionedMessageSource =
            DateSectionedMessageSource(event.messageSource);
        _sectionedMessageSource.addListener(_update);
        _messageLoader = initMessageSource();
      });
    });
  }

  Future<bool> initMessageSource() {
    //print('${DateTime.now()}: initMessageSource()');
    return _sectionedMessageSource.init();
    //print('${DateTime.now()}: loaded ${_sectionedMessageSource.size} messages');
  }

  @override
  void dispose() {
    searchEditingController.dispose();
    _sectionedMessageSource.removeListener(_update);
    _sectionedMessageSource.dispose();
    eventsSubscription.cancel();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  void search(String query) {
    if (query.isEmpty) {
      setState(() {
        isInSearchMode = false;
      });
      return;
    }
    final search = MailSearch(query, SearchQueryType.allTextHeaders);
    final searchSource = widget.messageSource.search(search);
    locator<NavigationService>()
        .push(Routes.messageSource, arguments: searchSource);
    setState(() {
      isInSearchMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final appBarTitle = isInSearchMode
        ? TextField(
            controller: searchEditingController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: localizations.homeSearchHint,
              hintStyle: TextStyle(color: Colors.white30),
              suffix: hasSearchInput
                  ? PlatformIconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchEditingController.text = '';
                        setState(() {
                          hasSearchInput = false;
                        });
                      },
                    )
                  : null,
            ),
            autofocus: true,
            autocorrect: false,
            style: TextStyle(color: Colors.white),
            onSubmitted: search,
            onChanged: (text) {
              if (text.isNotEmpty != hasSearchInput) {
                setState(() {
                  hasSearchInput = text.isNotEmpty;
                });
              }
            },
          )
        : Base.buildTitle(widget.messageSource.name ?? '',
            widget.messageSource.description ?? '');
    final appBarActions = [
      if (widget.messageSource.supportsSearching && !Platform.isIOS) ...{
        PlatformIconButton(
          icon: Icon(isInSearchMode ? Icons.arrow_back : Icons.search),
          onPressed: () {
            if (isInSearchMode) {
              setState(() {
                isInSearchMode = false;
              });
            } else {
              setState(() {
                isInSearchMode = true;
              });
            }
          },
        ),
      },
      if (!isInSearchMode) ...{
        PlatformPopupMenuButton<_Visualization>(
          onSelected: switchVisualization,
          itemBuilder: (context) => [
            _visualization == _Visualization.list
                ? PlatformPopupMenuItem<_Visualization>(
                    value: _Visualization.stack,
                    child: Text(localizations.homeActionsShowAsStack),
                  )
                : PlatformPopupMenuItem<_Visualization>(
                    value: _Visualization.list,
                    child: Text(localizations.homeActionsShowAsList),
                  ),
          ],
        ),
      },
    ];
    final i18nService = locator<I18nService>();
    Widget zeroPosWidget;
    if (_sectionedMessageSource.isInitialized &&
        widget.messageSource.size == 0) {
      final emptyMessage = widget.messageSource.isSearch
          ? localizations.homeEmptySearchMessage
          : localizations.homeEmptyFolderMessage;
      zeroPosWidget = Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
        child: Text(emptyMessage),
      );
    } else if (widget.messageSource.supportsDeleteAll) {
      final style = TextButton.styleFrom(primary: Colors.grey[600]);
      final textStyle =
          Theme.of(context).textTheme.button; //.copyWith(color: Colors.white);
      zeroPosWidget = Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Wrap(
          children: [
            TextButton.icon(
              style: style,
              icon: Icon(Icons.delete),
              label: Text(localizations.homeDeleteAllAction, style: textStyle),
              onPressed: () async {
                bool confirmed = await DialogHelper.askForConfirmation(context,
                    title: localizations.homeDeleteAllTitle,
                    query: localizations.homeDeleteAllQuestion,
                    action: localizations.homeDeleteAllAction,
                    isDangerousAction: true);
                if (confirmed == true) {
                  await widget.messageSource.deleteAllMessages();
                }
              },
            ),
            TextButton.icon(
              style: style,
              icon: Icon(Feather.circle),
              label:
                  Text(localizations.homeMarkAllSeenAction, style: textStyle),
              onPressed: () async {
                await widget.messageSource.markAllMessagesSeen(true);
              },
            ),
            TextButton.icon(
              style: style,
              icon: Icon(Icons.circle),
              label:
                  Text(localizations.homeMarkAllUnseenAction, style: textStyle),
              onPressed: () async {
                await widget.messageSource.markAllMessagesSeen(false);
              },
            ),
          ],
        ),
      );
    }
    return PlatformPageScaffold(
      bottomBar: isInSelectionMode
          ? buildSelectionModeBottomBar(localizations)
          : Platform.isIOS
              ? StatusBar(
                  rightAction: PlatformIconButton(
                    icon: Icon(CupertinoIcons.create),
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
        drawer: AppDrawer(),
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
                child: Icon(Icons.add),
                elevation: 2.0,
              ),
      ),
      // cupertino: (context, platform) => CupertinoPageScaffoldData(),
      appBar: (_visualization == _Visualization.stack)
          ? PlatformAppBar(
              title: appBarTitle,
              trailingActions: appBarActions,
              leading: (locator<MailService>().hasAccountsWithErrors())
                  ? MenuWithBadge()
                  : null,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localizations.homeLoading(
                            widget.messageSource.name ??
                                widget.messageSource.description)),
                      ),
                    ),
                  ],
                ),
              );
              break;
            case ConnectionState.done:
              if (_visualization == _Visualization.stack) {
                return WillPopScope(
                  onWillPop: () {
                    switchVisualization(_Visualization.list);
                    return Future.value(false);
                  },
                  child: MessageStack(messageSource: widget.messageSource),
                );
              }
              return WillPopScope(
                onWillPop: () {
                  if (isInSelectionMode) {
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
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      PlatformSliverAppBar(
                        title: appBarTitle,
                        leading:
                            (locator<MailService>().hasAccountsWithErrors())
                                ? MenuWithBadge()
                                : null,
                        floating: isInSearchMode ? false : true,
                        pinned: isInSearchMode ? true : false,
                        stretch: true,
                        actions: appBarActions,
                        previousPageTitle: localizations.accountsTitle,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            //print('building message item at $index');
                            if (zeroPosWidget != null) {
                              if (index == 0) {
                                return zeroPosWidget;
                              }
                              index--;
                            }
                            var element =
                                _sectionedMessageSource.getElementAt(index);
                            if (element.section != null) {
                              final text = i18nService.formatDateRange(
                                  element.section.range, element.section.date);
                              return GestureDetector(
                                onLongPress: () {
                                  selectedMessages = _sectionedMessageSource
                                      .getMessagesForSection(element.section);
                                  selectedMessages
                                      .forEach((m) => m.isSelected = true);
                                  setState(() {
                                    isInSelectionMode = true;
                                  });
                                },
                                onTap: !isInSelectionMode
                                    ? null
                                    : () {
                                        final sectionMessages =
                                            _sectionedMessageSource
                                                .getMessagesForSection(
                                                    element.section);
                                        final doSelect =
                                            !sectionMessages.first.isSelected;
                                        for (final msg in sectionMessages) {
                                          if (doSelect) {
                                            if (!msg.isSelected) {
                                              msg.isSelected = true;
                                              selectedMessages.add(msg);
                                            }
                                          } else {
                                            if (msg.isSelected) {
                                              msg.isSelected = false;
                                              selectedMessages.remove(msg);
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
                                        left: 16.0,
                                        right: 8.0,
                                        bottom: 4.0,
                                        top: 16.0,
                                      ),
                                      child: Text(
                                        text,
                                        style:
                                            TextStyle(color: theme.accentColor),
                                      ),
                                    ),
                                    Divider()
                                  ],
                                ),
                              );
                            }
                            final message = element.message;
                            final settings =
                                locator<SettingsService>().settings;
                            final swipeLeftToRightAction =
                                settings.swipeLeftToRightAction;
                            final swipeRightToLeftAction =
                                settings.swipeRightToLeftAction;
                            // print(
                            //     '$index subject=${message.mimeMessage?.decodeSubject()}');
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
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                alignment: AlignmentDirectional.centerStart,
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
                                        color:
                                            swipeLeftToRightAction.colorIcon),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: swipeRightToLeftAction.colorBackground,
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
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
                                element.message,
                                isInSelectionMode,
                                onMessageTap,
                                onMessageLongPress,
                              ),
                              onDismissed: (direction) {
                                final action =
                                    (direction == DismissDirection.startToEnd)
                                        ? swipeLeftToRightAction
                                        : swipeRightToLeftAction;
                                if (action.isMessageMoving) {
                                  fireSwipeAction(action, message);
                                }
                              },
                              confirmDismiss: (direction) {
                                if (direction == DismissDirection.startToEnd) {
                                  if (swipeLeftToRightAction.isMessageMoving) {
                                    return Future.value(true);
                                  } else {
                                    fireSwipeAction(
                                        swipeLeftToRightAction, message);
                                    return Future.value(false);
                                  }
                                } else {
                                  if (swipeRightToLeftAction.isMessageMoving) {
                                    return Future.value(true);
                                  } else {
                                    fireSwipeAction(
                                        swipeRightToLeftAction, message);
                                    return Future.value(false);
                                  }
                                }
                              },
                            );
                          },
                          childCount: _sectionedMessageSource.size +
                              ((zeroPosWidget != null) ? 1 : 0),
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
          return Container();
        },
      ),
    );
  }

  Widget buildSelectionModeBottomBar(AppLocalizations localizations) {
    final isTrash = widget.messageSource.isTrash;
    final isJunk = widget.messageSource.isJunk;
    final isAnyUnseen = selectedMessages.any((m) => !m.isSeen);
    final isAnyUnflagged = selectedMessages.any((m) => !m.isFlagged);
    return PlatformBottomBar(
      cupertinoBlurBackground: true,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('${selectedMessages.length}'),
            ),
            if (isAnyUnseen) ...{
              PlatformIconButton(
                icon: Icon(Icons.circle),
                onPressed: () => handleMultipleChoice(_MultipleChoice.seen),
              ),
            } else ...{
              PlatformIconButton(
                icon: Icon(Feather.circle),
                onPressed: () => handleMultipleChoice(_MultipleChoice.unseen),
              ),
            },
            if (isAnyUnflagged) ...{
              PlatformIconButton(
                icon: Icon(Icons.flag_outlined),
                onPressed: () => handleMultipleChoice(_MultipleChoice.flag),
              ),
            } else ...{
              PlatformIconButton(
                icon: Icon(Icons.flag),
                onPressed: () => handleMultipleChoice(_MultipleChoice.unflag),
              ),
            },
            if (isJunk) ...{
              PlatformIconButton(
                icon: Icon(Icons.check),
                onPressed: () => handleMultipleChoice(_MultipleChoice.inbox),
              ),
            } else ...{
              PlatformIconButton(
                icon: Icon(Entypo.bug),
                onPressed: () => handleMultipleChoice(_MultipleChoice.junk),
              ),
            },
            Spacer(),
            if (isTrash) ...{
              PlatformIconButton(
                icon: Icon(Entypo.inbox),
                onPressed: () => handleMultipleChoice(_MultipleChoice.inbox),
              ),
            } else ...{
              PlatformIconButton(
                icon: Icon(Icons.delete),
                onPressed: () => handleMultipleChoice(_MultipleChoice.delete),
              ),
            },
            PlatformIconButton(
              icon: Icon(Icons.close),
              onPressed: leaveSelectionMode,
            ),
            PlatformPopupMenuButton<_MultipleChoice>(
              onSelected: handleMultipleChoice,
              itemBuilder: (context) => [
                PlatformPopupMenuItem(
                  value: _MultipleChoice.forwardAsAttachment,
                  child: PlatformListTile(
                    leading: Icon(Icons.forward_to_inbox),
                    title: Text(localizations.messageActionForwardAsAttachment),
                  ),
                ),
                PlatformPopupMenuItem(
                  value: _MultipleChoice.forwardAttachments,
                  child: PlatformListTile(
                    leading: Icon(Icons.attach_file),
                    title: Text(localizations.messagesActionForwardAttachments),
                  ),
                ),
                if (isTrash) ...{
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.inbox,
                    child: PlatformListTile(
                      leading: Icon(Entypo.inbox),
                      title: Text(localizations.messageActionMoveToInbox),
                    ),
                  ),
                } else ...{
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.delete,
                    child: PlatformListTile(
                      leading: Icon(Icons.delete),
                      title: Text(localizations.messageActionDelete),
                    ),
                  ),
                },
                PlatformPopupDivider(),
                if (isAnyUnseen) ...{
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.seen,
                    child: PlatformListTile(
                      leading: Icon(Icons.circle),
                      title: Text(localizations.messageActionMultipleMarkSeen),
                    ),
                  ),
                } else ...{
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.unseen,
                    child: PlatformListTile(
                      leading: Icon(Feather.circle),
                      title:
                          Text(localizations.messageActionMultipleMarkUnseen),
                    ),
                  ),
                },
                if (isAnyUnflagged) ...{
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.flag,
                    child: PlatformListTile(
                      leading: Icon(Icons.outlined_flag),
                      title:
                          Text(localizations.messageActionMultipleMarkFlagged),
                    ),
                  ),
                } else ...{
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.unflag,
                    child: PlatformListTile(
                      leading: Icon(Icons.flag),
                      title: Text(
                          localizations.messageActionMultipleMarkUnflagged),
                    ),
                  ),
                },
                if (widget.messageSource.supportsMessageFolders) ...{
                  PlatformPopupDivider(),
                  PlatformPopupMenuItem(
                    value: _MultipleChoice.move,
                    child: PlatformListTile(
                      leading: Icon(MaterialCommunityIcons.file_move),
                      title: Text(localizations.messageActionMove),
                    ),
                  ),
                  if (isJunk) ...{
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.inbox,
                      child: PlatformListTile(
                        leading: Icon(Entypo.check),
                        title: Text(localizations.messageActionMarkAsNotJunk),
                      ),
                    ),
                  } else ...{
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.junk,
                      child: PlatformListTile(
                        leading: Icon(Entypo.bug),
                        title: Text(localizations.messageActionMarkAsJunk),
                      ),
                    ),
                  },
                  if (widget.messageSource.isArchive) ...{
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.inbox,
                      child: PlatformListTile(
                        leading: Icon(Entypo.inbox),
                        title: Text(localizations.messageActionUnarchive),
                      ),
                    ),
                  } else ...{
                    PlatformPopupMenuItem(
                      value: _MultipleChoice.archive,
                      child: PlatformListTile(
                        leading: Icon(Entypo.archive),
                        title: Text(localizations.messageActionArchive),
                      ),
                    ),
                  },
                },
              ],
            ),
          ],
        ),
      ),
    );
  }

  void handleMultipleChoice(_MultipleChoice choice) async {
    final localizations = locator<I18nService>().localizations;
    if (selectedMessages.isEmpty) {
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
            localizations.multipleMovedToTrash(selectedMessages.length);
        await widget.messageSource
            .deleteMessages(selectedMessages, notification);
        break;
      case _MultipleChoice.inbox:
        final notification =
            localizations.multipleMovedToInbox(selectedMessages.length);
        await widget.messageSource.moveMessagesToFlag(
            selectedMessages, MailboxFlag.inbox, notification);
        break;
      case _MultipleChoice.seen:
        endSelectionMode = false;
        await widget.messageSource.markMessagesAsSeen(selectedMessages, true);
        setState(() {});
        break;
      case _MultipleChoice.unseen:
        endSelectionMode = false;
        await widget.messageSource.markMessagesAsSeen(selectedMessages, false);
        setState(() {});
        break;
      case _MultipleChoice.flag:
        endSelectionMode = false;
        await widget.messageSource
            .markMessagesAsFlagged(selectedMessages, true);
        setState(() {});
        break;
      case _MultipleChoice.unflag:
        endSelectionMode = false;
        await widget.messageSource
            .markMessagesAsFlagged(selectedMessages, false);
        setState(() {});
        break;
      case _MultipleChoice.move:
        endSelectionMode = false;
        move();
        break;
      case _MultipleChoice.junk:
        final notification =
            localizations.multipleMovedToJunk(selectedMessages.length);
        await widget.messageSource.moveMessagesToFlag(
            selectedMessages, MailboxFlag.junk, notification);
        break;
      case _MultipleChoice.archive:
        final notification =
            localizations.multipleMovedToArchive(selectedMessages.length);
        await widget.messageSource.moveMessagesToFlag(
            selectedMessages, MailboxFlag.archive, notification);
        break;
    }
    if (endSelectionMode) {
      setState(() {
        isInSelectionMode = false;
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
      Future Function(Message, MessageBuilder) loader) async {
    final builder = MessageBuilder();
    final fromAddresses = <MailAddress>[];
    final subjects = <String>[];
    final futures = <Future>[];
    for (final message in selectedMessages) {
      message.isSelected = false;
      final mailClient = message.mailClient;
      final from = mailClient.account.fromAddress;
      if (!fromAddresses.contains(from)) {
        fromAddresses.add(from);
      }
      var mime = message.mimeMessage;
      final subject = mime.decodeSubject();
      if (subject?.isNotEmpty ?? false) {
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
        selectedMessages, builder, ComposeAction.forward,
        future: composeFuture);
    locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData, fade: true);
  }

  Future addMessageAttachment(Message message, MessageBuilder builder) {
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

  Future addAttachments(Message message, MessageBuilder builder) {
    final mailClient = message.mailClient;
    var mime = message.mimeMessage;
    Future composeFuture;
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
    var account = locator<MailService>().currentAccount;
    if (account.isVirtual) {
      // check how many mailclient are involved in the current selection to either show the mailboxes of the unified account
      // or of the real account
      final mailClients = <MailClient>[];
      for (final message in selectedMessages) {
        if (!mailClients.contains(message.mailClient)) {
          mailClients.add(message.mailClient);
        }
      }
      if (mailClients.length == 1) {
        // ok, all messages belong to one account:
        account =
            locator<MailService>().getAccountFor(mailClients.first.account);
      }
    }
    final mailbox = account.isVirtual
        ? null // //TODO set current mailbox, e.g.  current: widget.messageSource.currentMailbox,
        : selectedMessages.first.mailClient.selectedMailbox;
    DialogHelper.showWidgetDialog(
      context,
      localizations.multipleMoveTitle(selectedMessages.length),
      SingleChildScrollView(
        child: MailboxTree(
          account: account,
          onSelected: moveTo,
          current: mailbox,
        ),
      ),
      defaultActions: DialogActions.cancel,
    );
  }

  void moveTo(Mailbox mailbox) async {
    setState(() {
      isInSelectionMode = false;
    });
    locator<NavigationService>().pop(); // alert
    final localizations = locator<I18nService>().localizations;
    final account = locator<MailService>().currentAccount;
    if (account.isVirtual) {
      await widget.messageSource.moveMessagesToFlag(selectedMessages,
          mailbox.flags.first, localizations.moveSuccess(mailbox.name));
    } else {
      await widget.messageSource.moveMessages(
          selectedMessages, mailbox, localizations.moveSuccess(mailbox.name));
    }
  }

  void switchVisualization(_Visualization result) {
    setState(() {
      _visualization = result;
    });
  }

  void onMessageTap(Message message) async {
    if (isInSelectionMode) {
      message.toggleSelected();
      if (message.isSelected) {
        selectedMessages.add(message);
      } else {
        selectedMessages.remove(message);
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
    selectedMessages = [message];
    setState(() {
      isInSelectionMode = true;
    });
  }

  void leaveSelectionMode() {
    selectedMessages.forEach((m) => m.isSelected = false);
    selectedMessages = [];
    setState(() {
      isInSelectionMode = false;
    });
  }

  void fireSwipeAction(SwipeAction action, Message message) async {
    switch (action) {
      case SwipeAction.markRead:
        final isSeen = !message.isSeen;
        message.isSeen = isSeen;
        await message.mailClient
            .flagMessage(message.mimeMessage, isSeen: isSeen);
        break;
      case SwipeAction.archive:
        await _sectionedMessageSource.messageSource.archive(message);
        break;
      case SwipeAction.markJunk:
        await _sectionedMessageSource.messageSource.markAsJunk(message);
        break;
      case SwipeAction.delete:
        await _sectionedMessageSource.deleteMessage(message);
        break;
      case SwipeAction.flag:
        final isFlagged = !message.isFlagged;
        message.isFlagged = isFlagged;
        await message.mailClient
            .flagMessage(message.mimeMessage, isFlagged: isFlagged);
        break;
    }
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
}

class MessageOverview extends StatefulWidget {
  final Message message;
  final bool isInSelectionMode;
  final void Function(Message message) onTap;
  final void Function(Message message) onLongPress;
  final AnimationController animationController;

  MessageOverview(
      this.message, this.isInSelectionMode, this.onTap, this.onLongPress,
      {this.animationController})
      : super(key: ValueKey(message.sourceIndex));

  @override
  _MessageOverviewState createState() => _MessageOverviewState();
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
    final mime = widget.message.mimeMessage;
    if (mime == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: PlatformWidget(
          material: (context, platform) => ListTile(
            title: Text('...'),
            subtitle: Text('-'),
          ),
          cupertino: (context, platform) => Text('...'),
        ),
      );
    }

    return (widget.animationController != null)
        ? SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: widget.animationController,
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
            title: MessageOverviewContent(message: widget.message),
            onChanged: (value) => widget.onTap(widget.message),
          )
        : PlatformListTile(
            visualDensity: VisualDensity.compact,
            title: MessageOverviewContent(message: widget.message),
            onTap: () => widget.onTap(widget.message),
            onLongPress: () => widget.onLongPress(widget.message),
          );
  }
}
