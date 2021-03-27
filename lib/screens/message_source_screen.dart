import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/events/unified_messagesource_changed_event.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/date_sectioned_message_source.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_mail_app/widgets/message_stack.dart';
// import 'package:enough_style/enough_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                  ? IconButton(
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
      if (widget.messageSource.supportsSearching) ...{
        IconButton(
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
        PopupMenuButton<_Visualization>(
          onSelected: switchVisualization,
          itemBuilder: (context) => [
            _visualization == _Visualization.list
                ? PopupMenuItem<_Visualization>(
                    value: _Visualization.stack,
                    child: Text(localizations.homeActionsShowAsStack),
                  )
                : PopupMenuItem<_Visualization>(
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
      final emptyMessage = isInSearchMode
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
        child: Row(
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
              icon: Icon(Entypo.mail_with_circle),
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
    return Scaffold(
      drawer: AppDrawer(),
      floatingActionButton: _visualization == _Visualization.stack
          ? null
          : FloatingActionButton(
              onPressed: () {
                // locator<NotificationService>()
                //     .sendLocalNotificationForMailMessage(
                //         widget.messageSource.getMessageAt(3));
                locator<NavigationService>().push(
                  Routes.mailCompose,
                  arguments: ComposeData(
                      null, MessageBuilder(), ComposeAction.newMessage),
                );
              },
              tooltip: localizations.homeFabTooltip,
              child: Icon(Icons.add),
              elevation: 2.0,
            ),
      appBar: (_visualization == _Visualization.stack)
          ? AppBar(
              title: appBarTitle,
              actions: appBarActions,
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
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      title: appBarTitle,
                      floating: isInSearchMode ? false : true,
                      pinned: isInSearchMode ? true : false,
                      stretch: true,
                      actions: appBarActions,
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
                            return Column(
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
                                    style: TextStyle(color: theme.accentColor),
                                  ),
                                ),
                                Divider()
                              ],
                            );
                          }
                          final message = element.message;
                          // print(
                          //     '$index subject=${message.mimeMessage?.decodeSubject()}');
                          return Dismissible(
                            key: ValueKey(message),
                            dismissThresholds: {
                              DismissDirection.startToEnd: 0.3,
                              DismissDirection.endToStart: 0.5
                            },
                            background: Container(
                              color: Colors.amber[700],
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                        localizations.swipeActionToggleRead),
                                  ),
                                  Icon(
                                    Feather.circle,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              alignment: AlignmentDirectional.centerEnd,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child:
                                        Text(localizations.swipeActionDelete),
                                  ),
                                ],
                              ),
                            ),
                            child: (element.message?.mimeMessage?.sequenceId ==
                                    null)
                                ? Text('...')
                                : MessageOverview(
                                    element.message,
                                    isInSelectionMode,
                                    onMessageTap,
                                    onMessageLongPress,
                                  ),
                            onDismissed: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // left to right swipe action:
                                // is already handled in confirmDismiss
                              } else {
                                // right to left swipe action:
                                await _sectionedMessageSource
                                    .deleteMessage(message);
                              }
                            },
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                final isSeen = !message.isSeen;
                                message.isSeen = isSeen;
                                await message.mailClient.flagMessage(
                                    message.mimeMessage,
                                    isSeen: isSeen);
                                return false;
                              } else {
                                return true;
                              }
                            },
                          );
                        },
                        childCount: _sectionedMessageSource.size +
                            ((zeroPosWidget != null) ? 1 : 0),
                        semanticIndexCallback: (Widget widget, int localIndex) {
                          if (widget is MessageOverview) {
                            return widget.message.sourceIndex;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              );
          }
          return Container();
        },
      ),
      bottomNavigationBar: isInSelectionMode
          ? BottomAppBar(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('${selectedMessages.length}'),
                  ),
                  if (selectedMessages.any((m) => !m.isSeen)) ...{
                    IconButton(
                      icon: Icon(Entypo.mail_with_circle),
                      onPressed: () async {
                        await widget.messageSource
                            .markMessagesAsSeen(selectedMessages, true);
                        setState(() {});
                      },
                    ),
                  } else ...{
                    IconButton(
                      icon: Icon(Feather.circle),
                      onPressed: () async {
                        await widget.messageSource
                            .markMessagesAsSeen(selectedMessages, false);
                        setState(() {});
                      },
                    ),
                  },
                  if (selectedMessages.any((m) => !m.isFlagged)) ...{
                    IconButton(
                      icon: Icon(Icons.flag_outlined),
                      onPressed: () async {
                        await widget.messageSource
                            .markMessagesAsFlagged(selectedMessages, true);
                        setState(() {});
                      },
                    ),
                  } else ...{
                    IconButton(
                      icon: Icon(Icons.flag),
                      onPressed: () async {
                        await widget.messageSource
                            .markMessagesAsFlagged(selectedMessages, false);
                        setState(() {});
                      },
                    ),
                  },
                  IconButton(
                    icon: Icon(
                        widget.messageSource.isJunk ? Icons.check : Entypo.bug),
                    onPressed: () async {
                      final targetFlag = widget.messageSource.isJunk
                          ? MailboxFlag.inbox
                          : MailboxFlag.junk;
                      final notification = widget.messageSource.isJunk
                          ? localizations
                              .multipleMovedToInbox(selectedMessages.length)
                          : localizations
                              .multipleMovedToJunk(selectedMessages.length);
                      await widget.messageSource.moveMessages(
                          selectedMessages, targetFlag, notification);
                      leaveSelectionMode();
                    },
                  ),
                  IconButton(
                    icon: Icon(widget.messageSource.isArchive
                        ? Entypo.inbox
                        : Entypo.archive),
                    onPressed: () async {
                      final targetFlag = widget.messageSource.isJunk
                          ? MailboxFlag.inbox
                          : MailboxFlag.archive;
                      final notification = widget.messageSource.isArchive
                          ? localizations
                              .multipleMovedToInbox(selectedMessages.length)
                          : localizations
                              .multipleMovedToArchive(selectedMessages.length);
                      await widget.messageSource.moveMessages(
                          selectedMessages, targetFlag, notification);
                      leaveSelectionMode();
                    },
                  ),
                  Spacer(),
                  IconButton(
                      icon: Icon(widget.messageSource.isTrash
                          ? Entypo.inbox
                          : Icons.delete),
                      onPressed: () async {
                        if (widget.messageSource.isTrash) {
                          final notification = localizations
                              .multipleMovedToInbox(selectedMessages.length);
                          await widget.messageSource.moveMessages(
                              selectedMessages,
                              MailboxFlag.inbox,
                              notification);
                        } else {
                          final notification = localizations
                              .multipleMovedToTrash(selectedMessages.length);
                          await widget.messageSource
                              .deleteMessages(selectedMessages, notification);
                        }
                        leaveSelectionMode();
                      }),
                  IconButton(
                      icon: Icon(Icons.close), onPressed: leaveSelectionMode),
                ],
              ),
            )
          : null,
    );
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
        final data = ComposeData(message, builder, ComposeAction.newMessage);
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
      : super(key: ValueKey(message.mimeMessage.sequenceId.toString()));

  @override
  _MessageOverviewState createState() => _MessageOverviewState();
}

class _MessageOverviewState extends State<MessageOverview> {
  String subject;
  String sender;
  String date;
  bool hasAttachments;

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
    if (mime.isEmpty) {
      return ListTile(
        visualDensity: VisualDensity.compact,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(''), Text('...')],
        ),
      );
    }
    subject = mime.decodeSubject();
    MailAddress from;
    if (mime.from?.isNotEmpty ?? false) {
      from = mime.from.first;
    } else {
      from = mime.sender;
    }
    sender = sender = (from?.personalName?.isNotEmpty ?? false)
        ? from.personalName
        : from?.email != null
            ? from.email
            : AppLocalizations.of(context).emailSenderUnknown;
    hasAttachments = mime.hasAttachments();
    date = locator<I18nService>().formatDate(mime.decodeDate());
    final overview = buildMessageOverview();
    return (widget.animationController != null)
        ? SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: widget.animationController,
              curve: Curves.easeOut,
            ),
            child: overview,
          )
        : overview;
  }

  Widget buildMessageOverview() {
    return widget.isInSelectionMode
        ? CheckboxListTile(
            value: widget.message.isSelected,
            selected: widget.message.isSelected,
            title: buildMessageDetails(),
            onChanged: (value) => widget.onTap(widget.message),
          )
        : ListTile(
            visualDensity: VisualDensity.compact,
            title: buildMessageDetails(),
            onTap: () => widget.onTap(widget.message),
            onLongPress: () => widget.onLongPress(widget.message),
          );
  }

  Widget buildMessageDetails() {
    final message = widget.message;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: message.isFlagged ? Colors.amber[50] : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    sender,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                        fontWeight: message.isSeen
                            ? FontWeight.normal
                            : FontWeight.bold),
                  ),
                ),
              ),
              Text(date, style: TextStyle(fontSize: 12)),
              if (hasAttachments ||
                  message.isAnswered ||
                  message.isForwarded ||
                  message.isFlagged) ...{
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      if (message.isFlagged) ...{
                        Icon(Icons.outlined_flag, size: 12),
                      },
                      if (hasAttachments) ...{
                        Icon(Icons.attach_file, size: 12),
                      },
                      if (message.isAnswered) ...{
                        Icon(Icons.reply, size: 12),
                      },
                      if (message.isForwarded) ...{
                        Icon(Icons.forward, size: 12),
                      },
                    ],
                  ),
                ),
              }
            ],
          ),
          Text(
            subject ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight:
                    message.isSeen ? FontWeight.normal : FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
