import 'dart:math';

import 'package:flutter/material.dart';

typedef CollpaseWidgetBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class SliverCollapseHeader extends StatefulWidget {
  final double maxHeight;
  final double minHeight;
  final CollpaseWidgetBuilder builder;
  final Widget? expandedChild;
  final Widget? collapsedChild;
  final Color? backgroundColor;
  final bool? pinned;
  final bool? floating;
  final bool? snap;
  final bool? stretch;
  final double? stretchTriggerOffset;
  final ScrollController? scrollController;

  const SliverCollapseHeader({
    required this.maxHeight,
    required this.minHeight,
    required this.builder,
    this.expandedChild,
    this.collapsedChild,
    this.backgroundColor,
    this.pinned,
    this.floating,
    this.snap,
    this.stretch,
    this.stretchTriggerOffset,
    this.scrollController,
  });

  @override
  _SliverCollapseHeaderState createState() => _SliverCollapseHeaderState();
}

class _SliverCollapseHeaderState extends State<SliverCollapseHeader> {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: widget.pinned ?? true,
      floating: widget.floating ?? false,
      delegate: _SliverCollapseHeaderDelegate(
        maxHeight: widget.maxHeight,
        minHeight: widget.minHeight,
        builder: (context, shrinkOffset, overlapsContent) =>
            widget.builder(context, shrinkOffset, overlapsContent),
        expandedChild: widget.expandedChild,
        collapsedChild: widget.collapsedChild,
        backgroundColor: widget.backgroundColor,
        snap: widget.snap ?? false,
        stretch: widget.stretch ?? false,
        stretchTriggerOffset: widget.stretchTriggerOffset ?? 100.0,
        scrollController: widget.scrollController,
      ),
    );
  }
}

class _SliverCollapseHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final CollpaseWidgetBuilder builder;
  final Widget? expandedChild;
  final Widget? collapsedChild;
  final Color? backgroundColor;
  final bool snap;
  final bool stretch;
  final double stretchTriggerOffset;
  final ScrollController? scrollController;

  _SliverCollapseHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.builder,
    this.expandedChild,
    this.collapsedChild,
    this.backgroundColor,
    this.snap = false,
    this.stretch = false,
    this.stretchTriggerOffset = 100.0,
    this.scrollController,
  });

  @override
  double get minExtent => this.minHeight;
  @override
  double get maxExtent => this.maxHeight;

  double offset = 0;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double offset = shrinkOffset / (this.maxExtent - this.minExtent);
    return builder(context, min(1, offset), overlapsContent);
  }

  @override
  bool shouldRebuild(_SliverCollapseHeaderDelegate oldDelegate) {
    return true;
  }
}
