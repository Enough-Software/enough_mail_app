import 'package:flutter/material.dart';

class ActionPageView extends StatefulWidget {
  final List<Widget> children;
  final Widget action;
  final List<List<Color>> gradients;
  final double viewPortFraction;
  ActionPageView(
      {Key key,
      @required this.children,
      @required this.action,
      this.gradients,
      this.viewPortFraction = 1.0})
      : super(key: key);

  @override
  _ActionPageViewState createState() => _ActionPageViewState();
}

class _ActionPageViewState extends State<ActionPageView> {
  PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    pageController = PageController(viewportFraction: widget.viewPortFraction);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void pageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: widget.children.length,
            itemBuilder: (context, index) => Container(
              decoration: widget.gradients == null
                  ? null
                  : BoxDecoration(
                      gradient: LinearGradient(colors: widget.gradients[index]),
                    ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.children[index],
              ),
            ),
            onPageChanged: pageChanged,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Radio(
                        groupValue: currentPage,
                        value: index,
                        onChanged: (value) => pageController.jumpToPage(value),
                        activeColor: Color(0x99ffffff),
                      ),
                      itemCount: widget.children.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                  widget.action
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
