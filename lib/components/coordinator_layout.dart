import 'package:dashboard_template/components/header.dart';
import 'package:flutter/material.dart';

class CoordinatorLayout extends StatefulWidget {
  const CoordinatorLayout({
    Key? key,
    required this.header,
    required this.body,
    required this.scrollController,
    this.snap = true,
    this.overlap = false,
  }) : super(key: key);

  final SliverCollapseHeader header;
  final Widget body;
  final ScrollController scrollController;
  final bool snap;
  final bool overlap;

  @override
  _CoordinatorLayoutState createState() => _CoordinatorLayoutState();
}

class _CoordinatorLayoutState extends State<CoordinatorLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildNestedScrollView();
  }

  Widget buildNestedScrollView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification && widget.snap) {
          final double range =
              widget.header.maxHeight - widget.header.minHeight;
          if (widget.scrollController.offset > 0 &&
              widget.scrollController.offset < range) {
            if (widget.scrollController.offset < range / 2) {
              widget.scrollController
                  .animateTo(0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.ease)
                  .then((value) => widget.scrollController.jumpTo(0));
            } else if (widget.scrollController.offset < range) {
              widget.scrollController
                  .animateTo(range,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.ease)
                  .then((value) => widget.scrollController.jumpTo(range));
            }
          }
        }
        return false;
      },
      child: NestedScrollView(
        controller: widget.scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [widget.header];
        },
        body: SingleChildScrollView(
          child: widget.body,
        ),
      ),
    );
  }
}
