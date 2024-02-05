import 'dart:math';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../models/message.dart';
import '../models/message_source.dart';
import '../scaffold_messenger/service.dart';
import 'mail_address_chip.dart';

enum _DragAction { noted, later, delete, reply }

/// A stack of messages that can be processed.
class MessageStack extends StatefulHookConsumerWidget {
  /// Creates a new [MessageStack] widget.
  const MessageStack({super.key, required this.messageSource});

  /// The message source from which the messages are taken.
  final MessageSource messageSource;

  @override
  ConsumerState<MessageStack> createState() => _MessageStackState();
}

class _MessageStackState extends ConsumerState<MessageStack> {
  static final _random = Random();
  int _currentMessageIndex = 0;
  Message? _currentMessage;
  double? _currentAngle;
  final List<Message> _nextMessages = [];
  final List<double> _nextAngles = [];

  double createAngle() => (_random.nextInt(200) - 100.0) / 4000;

  @override
  void initState() {
    // _currentMessage = widget.messageSource!.getMessageAt(0);
    // _currentAngle = createAngle();
    // for (var i = 1; i < math.min(3, widget.messageSource!.size); i++) {
    //   _nextMessages.add(widget.messageSource!.getMessageAt(i));
    //   _nextAngles.add(createAngle());
    // }
    super.initState();
  }

  void moveToNextMessage() {
    setState(() {
      _currentMessageIndex++;
      if (_nextMessages.isEmpty) {
        _currentMessage = null;
      } else {
        _currentMessage = _nextMessages.first;
        _currentAngle = _nextAngles.first;
        _nextMessages.removeAt(0);
        _nextAngles.removeAt(0);
        if (widget.messageSource.size > _currentMessageIndex + 3) {
          // _nextMessages.add(
          //     widget.messageSource!.getMessageAt(_currentMessageIndex + 3));
          _nextAngles.add(createAngle());
        }
      }
    });
  }

  void moveToPreviousMessage() {
    final currentMessage = _currentMessage;
    if (currentMessage != null && _currentMessageIndex > 0) {
      setState(() {
        _nextMessages.insert(0, currentMessage);
        _nextAngles.insert(0, createAngle());
        _currentMessageIndex--;
        // _currentMessage =
        //     widget.messageSource!.getMessageAt(_currentMessageIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickReplies = ['OK', 'Thank you!', '👍', '😊'];
    final dateTime = _currentMessage?.mimeMessage.decodeDate();
    final dayName = dateTime == null ? '' : ref.formatDay(dateTime);
    final currentMessage = _currentMessage;

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        // center: stack of messages
        for (var i = _nextMessages.length; --i >= 0;)
          Padding(
            padding: const EdgeInsets.all(30),
            child: MessageCard(
              message: _nextMessages[i],
              angle: _nextAngles[i],
            ),
          ),

        // top right: day of message
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              dayName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        // right: delete
        Align(
          alignment: Alignment.centerRight,
          child: _MessageDragTarget(
            action: _DragAction.delete,
            onComplete: acceptDragOperation,
            width: 100,
            height: 200,
          ),
        ),
        // top: noted (read)
        Align(
          alignment: Alignment.topCenter,
          child: _MessageDragTarget(
            action: _DragAction.noted,
            onComplete: acceptDragOperation,
            width: 200,
            height: 100,
          ),
        ),
        // left: later
        Align(
          alignment: Alignment.centerLeft,
          child: _MessageDragTarget(
            action: _DragAction.later,
            onComplete: acceptDragOperation,
            width: 100,
            height: 200,
          ),
        ),
        // bottom: quick replies
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...quickReplies.map(
                (reply) => _MessageDragTarget(
                  data: reply,
                  action: _DragAction.reply,
                  onComplete: acceptDragOperation,
                  width: 50,
                  height: 100,
                ),
              ),
            ],
          ),
        ),
        // bottom left: back
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: PlatformIconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  _currentMessageIndex == 0 ? null : moveToPreviousMessage,
            ),
          ),
        ),
        // center: first / current message
        if (currentMessage != null)
          Padding(
            padding: const EdgeInsets.all(30),
            child: _MessageDraggable(
              message: currentMessage,
              angle: _currentAngle ?? 0,
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: Text('All messages processed, well done!')),
          ),
      ],
    );
  }

  Future<void> acceptDragOperation(
    Message message,
    _DragAction action, {
    Object? data,
  }) async {
    moveToNextMessage();
    //print('drag operation: $action');
    String? snack;
    late Future<void> Function() undo;
    switch (action) {
      case _DragAction.noted:
        if (!message.isSeen) {
          await message.source.markAsSeen(message, true);
          snack = 'mark as read';
        }
        break;
      case _DragAction.later:
        // nothing to do, just move on?
        break;
      case _DragAction.delete:
        // TODO(RV): remove from message source
        await message.source.storeMessageFlags(
          [message],
          [MessageFlags.deleted],
        );
        snack = 'deleted';
        undo = () => message.source.storeMessageFlags(
              [message],
              [MessageFlags.deleted],
              action: StoreAction.remove,
            ); // TODO(RV): add re-integration into message source
        break;
      case _DragAction.reply:
        // TODO(RV): implement quick reply
        snack = 'replied with $data';
        break;
    }
    if (snack != null) {
      if (context.mounted) {
        // TODO(RV): allow undo when marking as deleted
        ScaffoldMessengerService.instance.showTextSnackBar(
          ref.text,
          snack,
          undo: () async {
            // bring back message:
            setState(() {
              _currentMessage = message;
              _currentMessageIndex = message.sourceIndex;
            });
            await undo();
          },
        );
      }
    }
  }
}

class _MessageDragTarget extends StatefulWidget {
  const _MessageDragTarget({
    required this.action,
    required this.onComplete,
    this.data,
    this.width,
    this.height,
  });

  final _DragAction action;
  final Object? data;
  final Function(Message message, _DragAction action, {Object? data})
      onComplete;
  final double? width;
  final double? height;

  @override
  State<_MessageDragTarget> createState() => _MessageDragTargetState();
}

class _MessageDragTargetState extends State<_MessageDragTarget> {
  late double width;
  late double height;
  Color? color;
  late String text;

  double? _originalWidth;
  double? _originalHeight;
  Color? _originalColor;

  @override
  void initState() {
    width = widget.width ?? 100;
    height = widget.height ?? 100;
    switch (widget.action) {
      case _DragAction.noted:
        color = Colors.green[300];
        text = 'Noted';
        break;
      case _DragAction.later:
        color = Colors.yellow[300];
        text = 'Later';
        break;
      case _DragAction.delete:
        color = Colors.red[300];
        text = 'Delete';
        break;
      case _DragAction.reply:
        color = Colors.yellow[300];
        text = widget.data?.toString() ?? 'Reply';
        break;
    }
    _originalWidth = width;
    _originalHeight = height;
    _originalColor = color;
    super.initState();
  }

  void startAccepting() {
    final originalWidth = _originalWidth;
    if (originalWidth != null && width == originalWidth) {
      setState(() {
        width = originalWidth * 1.2;
        height = (_originalHeight ?? originalWidth) * 1.2;
        color = Color.lerp(_originalColor, Colors.black, 0.3);
      });
    }
  }

  void endAccepting() {
    setState(() {
      width = _originalWidth ?? 100;
      height = _originalHeight ?? 100;
      color = _originalColor;
    });
  }

  @override
  Widget build(BuildContext context) => DragTarget<Message>(
        builder: (context, candidateData, rejectedData) => Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(width / 5),
            ),
            width: width,
            height: height,
            alignment: Alignment.centerLeft,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut,
            child: Center(child: Text(text)),
          ),
        ),
        onWillAccept: (data) {
          startAccepting();

          return true;
        },
        onAccept: (data) async {
          endAccepting();
          widget.onComplete(data, widget.action, data: widget.data);
        },
        onLeave: (data) => endAccepting(),
      );
}

class _MessageDraggable extends StatefulWidget {
  const _MessageDraggable({
    required this.message,
    required this.angle,
  });
  final Message message;
  final double angle;

  @override
  State<_MessageDraggable> createState() => _MessageDraggableState();
}

class _MessageDraggableState extends State<_MessageDraggable>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: Tween<double>(begin: 1, end: 0.5).animate(_animationController),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            Draggable<Message>(
          data: widget.message,
          feedback: ConstrainedBox(
            constraints: constraints,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _scaleAnimation,
                child: MessageCard(
                  message: widget.message,
                  angle: widget.angle,
                ),
              ),
            ),
          ),
          childWhenDragging: Container(),
          maxSimultaneousDrags: 1,
          onDragStarted: () {
            _animationController
              ..reset()
              ..forward();
          },
          child: MessageCard(message: widget.message, angle: widget.angle),
        ),
      );
}

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message, required this.angle});
  final Message message;
  final double angle;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  void initState() {
    widget.message.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    widget.message.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: widget.angle,
        child: Card(
          elevation: 18,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: widget.message.mimeMessage.isEmpty
                  ? const Text('...')
                  : buildMessageContents(),
            ),
          ),
        ),
      );

  Widget buildMessageContents() {
    final mime = widget.message.mimeMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mime.decodeSubject() ?? ''),
        Row(
          children: [
            const Text('From '),
            for (final address in mime.from ?? const [])
              MailAddressChip(mailAddress: address),
          ],
        ),
        if (mime.to?.isNotEmpty ?? false)
          Wrap(
            children: [
              const Text('To '),
              for (final address in mime.to ?? const [])
                MailAddressChip(mailAddress: address),
            ],
          ),
        if (mime.cc?.isNotEmpty ?? false)
          Wrap(
            children: [
              const Text('CC '),
              for (final address in mime.cc ?? const [])
                MailAddressChip(mailAddress: address),
            ],
          ),
        buildContent(),
      ],
    );
  }

  Widget buildContent() {
    // TODO(RV): do not download or display the content
    // when the widget is not exposed, unless the content is there already
    if (!widget.message.mimeMessage.isDownloaded) {
      return FutureBuilder(
        future: downloadMessageContents(widget.message),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: PlatformProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Text('Unable to download message');
              }
              break;
          }

          return buildMessageContent(context);
        },
      );
    }

    return buildMessageContent(context);
  }

  Future<Message> downloadMessageContents(Message message) async {
    try {
      final mime = await message.source.fetchMessageContents(message);
      if (mime.isNewsletter || mime.hasAttachments()) {
        setState(() {});
      }
    } on MailException catch (e) {
      if (kDebugMode) {
        print('unable to download message contents: $e');
      }
    }

    return message;
  }

  Widget buildMessageContent(BuildContext context) {
    // var html = widget.message.decodeAndStripHtml();
    // if (html != null && false) {
    //   String contentBase64 = base64Encode(const Utf8Encoder().convert(html));
    // return WebView(
    //   key: ValueKey(widget.message),
    //   javascriptMode: JavascriptMode.disabled,
    //   gestureRecognizers: null,
    //   initialUrl: 'data:text/html;base64,$contentBase64',
    //   onWebViewCreated: (controller) {
    //     //_webViewController = controller;
    //     //controller.
    //     print('created webview');
    //   },
    //   onPageFinished: (url) {
    //     print('finished loading page');
    // TODO(RV): inject JS to query size?
    //   },
    // );
    // }
    // if (html != null && html.indexOf(' colspan=') == -1) {
    //   Html(
    //     data: html,
    //     onLinkTap: (url) => urlLauncher.launch(url),
    //   );
    // }
    final text = widget.message.mimeMessage.decodeTextPlainPart();
    if (text != null) {
      return SelectableText(text);
    }
    // TODO(RV): add other content, attachments, etc

    return Text(
      'Unsupported content: ${widget.message.mimeMessage.mediaType.text}',
    );
  }
}
