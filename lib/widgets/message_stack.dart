import 'dart:convert';
import 'dart:math';

import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/widgets/mail_address_chip.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'dart:math' as math;

enum DragAction { noted, later, delete, reply }

class MessageStack extends StatefulWidget {
  final MessageSource messageSource;
  MessageStack({Key key, @required this.messageSource}) : super(key: key);

  @override
  _MessageStackState createState() => _MessageStackState();
}

class _MessageStackState extends State<MessageStack> {
  static final random = Random();
  int currentMessageIndex = 0;
  Message currentMessage;
  double currentAngle;
  List<Message> nextMessages = [];
  List<double> nextAngles = [];

  double createAngle() {
    return (random.nextInt(200) - 100.0) / 4000;
  }

  @override
  void initState() {
    currentMessage = widget.messageSource.getMessageAt(0);
    currentAngle = createAngle();
    for (var i = 1; i < math.min(3, widget.messageSource.size); i++) {
      nextMessages.add(widget.messageSource.getMessageAt(i));
      nextAngles.add(createAngle());
    }
    super.initState();
  }

  void moveToNextMessage() {
    setState(() {
      currentMessageIndex++;
      if (nextMessages.isEmpty) {
        currentMessage = null;
      } else {
        currentMessage = nextMessages.first;
        currentAngle = nextAngles.first;
        nextMessages.removeAt(0);
        nextAngles.removeAt(0);
        if (widget.messageSource.size > currentMessageIndex + 3) {
          nextMessages
              .add(widget.messageSource.getMessageAt(currentMessageIndex + 3));
          nextAngles.add(createAngle());
        }
      }
    });
  }

  void moveToPreviousMessage() {
    if (currentMessage != null && currentMessageIndex > 0) {
      setState(() {
        nextMessages.insert(0, currentMessage);
        nextAngles.insert(0, createAngle());
        currentMessageIndex--;
        currentMessage = widget.messageSource.getMessageAt(currentMessageIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickReplies = ['OK', 'Thank you!', '👍', '😊'];
    final dateTime = currentMessage.mimeMessage.decodeDate();
    final dayName = dateTime == null
        ? ''
        : locator<I18nService>().formatDay(dateTime, context);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        // center: stack of messages
        for (var i = nextMessages.length; --i >= 0;) ...{
          Padding(
            padding: EdgeInsets.all(30),
            child: MessageCard(
              message: nextMessages[i],
              angle: nextAngles[i],
            ),
          ),
        },
        // top right: day of message
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dayName,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ),
        // right: delete
        Align(
          alignment: Alignment.centerRight,
          child: MessageDragTarget(
            action: DragAction.delete,
            onComplete: acceptDragOperation,
            width: 100,
            height: 200,
          ),
        ),
        // top: noted (read)
        Align(
          alignment: Alignment.topCenter,
          child: MessageDragTarget(
            action: DragAction.noted,
            onComplete: acceptDragOperation,
            width: 200,
            height: 100,
          ),
        ),
        // left: later
        Align(
          alignment: Alignment.centerLeft,
          child: MessageDragTarget(
            action: DragAction.later,
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
              ...quickReplies.map((reply) => MessageDragTarget(
                  data: reply,
                  action: DragAction.reply,
                  onComplete: acceptDragOperation,
                  width: 50,
                  height: 100))
            ],
          ),
        ),
        // bottom left: back
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed:
                  currentMessageIndex == 0 ? null : moveToPreviousMessage,
            ),
          ),
        ),
        // center: first / current message
        if (currentMessage != null) ...{
          Padding(
            padding: EdgeInsets.all(30),
            child: MessageDraggable(
              message: currentMessage,
              angle: currentAngle,
            ),
          ),
        } else ...{
          Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: Text('All messages processed, well done!')),
          ),
        },
      ],
    );
  }

  Future<void> acceptDragOperation(Message message, DragAction action,
      {Object data}) async {
    moveToNextMessage();
    //print('drag operation: $action');
    String snack;
    Future<void> Function() undo;
    switch (action) {
      case DragAction.noted:
        if (!message.isSeen) {
          await message.mailClient
              .flagMessage(message.mimeMessage, isSeen: true);
          snack = 'mark as read';
        }
        break;
      case DragAction.later:
        // nothing to do, just move on?
        break;
      case DragAction.delete:
        //TODO remove from message source
        await message.mailClient
            .flagMessage(message.mimeMessage, isDeleted: true);
        snack = 'deleted';
        undo = () => message.mailClient.flagMessage(message.mimeMessage,
            isDeleted: false); //TODO add re-integration into message source
        break;
      case DragAction.reply:
        //TODO implement quick reply
        snack = 'replied with $data';
        break;
    }
    if (snack != null) {
      //TODO allow undo when marking as deleted
      final snackBar = SnackBar(
        content: Text(snack),
        action: undo == null
            ? null
            : SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  // bring back message:
                  setState(() {
                    currentMessage = message;
                    currentMessageIndex = message.sourceIndex;
                  });
                  await undo();
                },
              ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }
}

class MessageDragTarget extends StatefulWidget {
  final DragAction action;
  final Object data;
  final Function(Message message, DragAction action, {Object data}) onComplete;
  final double width;
  final double height;
  MessageDragTarget(
      {Key key,
      @required this.action,
      @required this.onComplete,
      this.data,
      this.width,
      this.height})
      : super(key: key);

  @override
  _MessageDragTargetState createState() => _MessageDragTargetState();
}

class _MessageDragTargetState extends State<MessageDragTarget> {
  double width;
  double height;
  Color color;
  String text;

  double _originalWidth;
  double _originalHeight;
  Color _originalColor;

  @override
  void initState() {
    width = widget.width ?? 100;
    height = widget.height ?? 100;
    switch (widget.action) {
      case DragAction.noted:
        color = Colors.green[300];
        text = 'Noted';
        break;
      case DragAction.later:
        color = Colors.yellow[300];
        text = 'Later';
        break;
      case DragAction.delete:
        color = Colors.red[300];
        text = 'Delete';
        break;
      case DragAction.reply:
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
    if (width == _originalWidth) {
      setState(() {
        width = _originalWidth * 1.2;
        height = _originalHeight * 1.2;
        color = Color.lerp(_originalColor, Colors.black, 0.3);
      });
    }
  }

  void endAccepting() {
    setState(() {
      width = _originalWidth;
      height = _originalHeight;
      color = _originalColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Message>(
      builder: (context, candidateData, rejectedData) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
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
        );
      },
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
}

class MessageDraggable extends StatefulWidget {
  final Message message;
  final double angle;

  const MessageDraggable({Key key, this.message, this.angle}) : super(key: key);

  @override
  _MessageDraggableState createState() => _MessageDraggableState();
}

class _MessageDraggableState extends State<MessageDraggable>
    with TickerProviderStateMixin {
  AnimationController animationController;
  Animation scaleAnimation;

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    scaleAnimation = CurvedAnimation(
        curve: Curves.easeInOut,
        parent: Tween(begin: 1.0, end: 0.5).animate(animationController));
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Draggable<Message>(
          data: widget.message,
          feedback: ConstrainedBox(
              constraints: constraints,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: FadeTransition(
                  opacity: scaleAnimation,
                  child:
                      MessageCard(message: widget.message, angle: widget.angle),
                ),
              )),
          child: MessageCard(message: widget.message, angle: widget.angle),
          childWhenDragging: Container(),
          maxSimultaneousDrags: 1,
          dragAnchor: DragAnchor.child,
          onDragStarted: () {
            animationController.reset();
            animationController.forward();
          },
        );
      },
    );
  }
}

class MessageCard extends StatefulWidget {
  final Message message;
  final double angle;
  const MessageCard({Key key, @required this.message, this.angle})
      : super(key: key);

  @override
  _MessageCardState createState() => _MessageCardState();
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
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.angle,
      child: Card(
        elevation: 18,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.message.mimeMessage.isEmpty
                ? Text('...')
                : buildMessageContents(),
          ),
        ),
      ),
    );
  }

  Widget buildMessageContents() {
    final mime = widget.message.mimeMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(mime.decodeSubject()),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('From '),
            for (final address in mime.from) ...{
              MailAddressChip(mailAddress: address),
            },
          ],
        ),
        if (mime.to?.isNotEmpty ?? false) ...{
          Wrap(
            children: [
              Text('To '),
              for (final address in mime.to) ...{
                MailAddressChip(mailAddress: address),
              },
            ],
          ),
        },
        if (mime.cc?.isNotEmpty ?? false) ...{
          Wrap(
            children: [
              Text('CC '),
              for (final address in mime.cc) ...{
                MailAddressChip(mailAddress: address),
              },
            ],
          ),
        },
        buildContent(),
      ],
    );
  }

  Widget buildContent() {
    //TODO do not download or display the content
    // when the widget is not exposed, unless the content is there already
    if (!widget.message.mimeMessage.isDownloaded) {
      return FutureBuilder(
          future: downloadMessageContents(widget.message),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Container(child: CircularProgressIndicator());
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Unable to download message');
                }
                break;
            }
            return buildMessageContent(context);
          });
    }
    return buildMessageContent(context);
  }

  Future<Message> downloadMessageContents(Message message) async {
    var mimeResponse =
        await message.mailClient.fetchMessageContents(message.mimeMessage);
    if (mimeResponse.isOkStatus) {
      final mime = mimeResponse.result;
      message.updateMime(mime);
      if (mime.isNewsletter || mime.hasAttachments()) {
        setState(() {});
      }
    }
    return message;
  }

  Widget buildMessageContent(BuildContext context) {
    var html = widget.message.decodeAndStripHtml();
    if (html != null && false) {
      String contentBase64 = base64Encode(const Utf8Encoder().convert(html));
      return WebView(
        key: ValueKey(widget.message),
        javascriptMode: JavascriptMode.disabled,
        gestureRecognizers: null,
        initialUrl: 'data:text/html;base64,$contentBase64',
        onWebViewCreated: (controller) {
          //_webViewController = controller;
          //controller.
          print('created webview');
        },
        onPageFinished: (url) {
          print('finished loading page');
          //TODO inject JS to query size?
        },
      );
    }
    // if (html != null && html.indexOf(' colspan=') == -1) {
    //   Html(
    //     data: html,
    //     onLinkTap: (url) => urlLauncher.launch(url),
    //   );
    // }
    var text = widget.message.mimeMessage.decodeTextPlainPart();
    if (text != null) {
      return SelectableText(text);
    }
    //TODO add other content, attachments, etc
    return Text(
        'Unsupported content: ${widget.message.mimeMessage.mediaType?.text}');
  }
}
