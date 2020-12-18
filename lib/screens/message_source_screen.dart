import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/date_sectioned_message_source.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/alert_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_mail_app/widgets/message_stack.dart';
// import 'package:enough_style/enough_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

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

  @override
  void initState() {
    super.initState();
    _sectionedMessageSource = DateSectionedMessageSource(widget.messageSource);
    //widget.messageSource.addListener(_update);
    _sectionedMessageSource.addListener(_update);
    _messageLoader = initMessageSource();
  }

  Future<bool> initMessageSource() {
    print('${DateTime.now()}: loadMessages()');
    return _sectionedMessageSource.init();
    //print('${DateTime.now()}: loaded ${_sectionedMessageSource.size} messages');
  }

  @override
  void dispose() {
    //widget.messageSource.removeListener(_update);
    _sectionedMessageSource.removeListener(_update);
    _sectionedMessageSource.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTitle = Base.buildTitle(widget.messageSource.name ?? '',
        widget.messageSource.description ?? '');
    final appBarActions = [
      PopupMenuButton<_Visualization>(
        onSelected: switchVisualization,
        itemBuilder: (context) => [
          _visualization == _Visualization.list
              ? const PopupMenuItem<_Visualization>(
                  value: _Visualization.stack,
                  child: Text('Show as stack'),
                )
              : const PopupMenuItem<_Visualization>(
                  value: _Visualization.list,
                  child: Text('Show as list'),
                ),
        ],
      ),
    ];
    final i18nService = locator<I18nService>();
    Widget zeroPosWidget;
    if (_sectionedMessageSource.isInitialized &&
        widget.messageSource.size == 0) {
      zeroPosWidget = Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
        child: Text('All done!\n\nThere are no messages in this folder.'),
      );
    } else if (widget.messageSource.supportsDeleteAll) {
      final style = TextButton.styleFrom(primary: Colors.grey[600]);
      final textStyle =
          Theme.of(context).textTheme.button; //.copyWith(color: Colors.white);
      zeroPosWidget = Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: TextButton.icon(
          style: style,
          icon: Icon(Icons.delete),
          label: Text('Delete all', style: textStyle),
          onPressed: () async {
            bool confirmed = await locator<AlertService>().askForConfirmation(
                context,
                title: 'Confirm',
                query: 'Really delete all messages?',
                action: 'Delete all',
                isDangerousAction: true);
            if (confirmed == true) {
              await widget.messageSource.deleteAllMessages();
            }
          },
        ),
      );
    }
    return Scaffold(
      drawer: AppDrawer(),
      floatingActionButton: _visualization == _Visualization.stack
          ? null
          : FloatingActionButton(
              onPressed: () {
                locator<NavigationService>().push(Routes.mailCompose,
                    arguments: ComposeData(
                        null, MessageBuilder(), ComposeAction.newMessage));
              },
              tooltip: 'New message',
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
                          child: Text(
                              'loading messages for ${widget.messageSource.name ?? widget.messageSource.description}...'),
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
                return CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      title: appBarTitle,
                      floating: true,
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
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                children: [
                                  Text(' mark as read/unread '),
                                  Icon(
                                    Feather.circle,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: AlignmentDirectional.centerEnd,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  Text('delete '),
                                ],
                              ),
                            ),
                            child: MessageOverview(element.message),
                            onDismissed: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // left to right swipe action:
                                // is already handled in confirmDismiss
                              } else {
                                // right to left swipe action:
                                await _sectionedMessageSource.deleteMessage(
                                    context, message);
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
                );
            }
            return Container();
          }),
    );
  }

  void switchVisualization(_Visualization result) {
    setState(() {
      _visualization = result;
    });
  }
}

class MessageOverview extends StatefulWidget {
  final Message message;
  final AnimationController animationController;
  MessageOverview(this.message, {this.animationController})
      : super(key: ValueKey(message.mimeMessage.sequenceId.toString()));

  @override
  _MessageOverviewState createState() => _MessageOverviewState(message);
}

class _MessageOverviewState extends State<MessageOverview> {
  final Message message;
  String subject;
  String sender;
  String date;
  bool hasAttachments;

  _MessageOverviewState(this.message);

  @override
  void dispose() {
    message.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  void initState() {
    message.addListener(_update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mime = message.mimeMessage;
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
            : '<no sender>';
    hasAttachments = mime.hasAttachments();
    date = locator<I18nService>().formatDate(mime.decodeDate(), context);
    var overview = buildMessageOverview();
    return widget.animationController != null
        ? SizeTransition(
            sizeFactor: CurvedAnimation(
                parent: widget.animationController, curve: Curves.easeOut),
            child: overview)
        : overview;
  }

  Widget buildMessageOverview() {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        color: message.isFlagged ? Colors.amber[50] : null,
        // child: Slidable(
        //   actionPane: SlidableDrawerActionPane(),
        //   actionExtentRatio: 0.25,
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
        //   actions: <Widget>[
        //     // IconSlideAction(
        //     //   caption: 'Archive',
        //     //   color: Colors.blue,
        //     //   icon: Icons.archive,
        //     //   onTap: () => _showSnackBar('Archive'),
        //     // ),
        //     // IconSlideAction(
        //     //   caption: 'Share',
        //     //   color: Colors.indigo,
        //     //   icon: Icons.share,
        //     //   onTap: () => _showSnackBar('Share'),
        //     // ),
        //     if (message.isSeen) ...{
        //       IconSlideAction(
        //         caption: 'Unread',
        //         color: Colors.indigo,
        //         icon: Icons.check_circle_outline,
        //         onTap: () async {
        //           message.isSeen = false;
        //           await message.mailClient
        //               .flagMessage(message.mimeMessage, isSeen: false);
        //         },
        //       )
        //     } else ...{
        //       IconSlideAction(
        //         caption: 'Read',
        //         color: Colors.indigo,
        //         icon: Icons.check_circle,
        //         onTap: () async {
        //           message.isSeen = true;
        //           await message.mailClient
        //               .flagMessage(message.mimeMessage, isSeen: true);
        //         },
        //       )
        //     }
        //   ],
        //   secondaryActions: <Widget>[
        //     IconSlideAction(
        //       caption: 'More',
        //       color: Colors.black45,
        //       icon: Icons.more_horiz,
        //       onTap: () => _showSnackBar('More'),
        //     ),
        //     IconSlideAction(
        //       caption: 'Delete',
        //       color: Colors.red,
        //       icon: Icons.delete,
        //       onTap: () {
        //         //widget.messageSource.deleteMessage(message);
        //       },
        //     ),
        //   ],
        // ),
      ),
      onTap: () {
        locator<NavigationService>()
            .push(Routes.mailDetails, arguments: message);
      },
    );
  }
}
