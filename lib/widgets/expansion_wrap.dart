// ignore_for_file: avoid_setters_without_getters

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The position of the indicator.
enum ExpansionWrapIndicatorPosition {
  /// The indicator is placed at the end of the last visible line.
  inline,

  /// The indicator is placed at the end of the last visible line, but
  /// aligned to the right border of the widget.
  border,
}

/// A widget that displays its children in a wrap layout and adds an indicator
/// at the end if the children do not fit in the available space.
class ExpansionWrap extends RenderObjectWidget {
  /// Creates a new [ExpansionWrap] widget.
  const ExpansionWrap({
    super.key,
    required this.children,
    required this.expandIndicator,
    required this.maxRuns,
    required this.compressIndicator,
    this.isExpanded = false,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.indicatorPosition = ExpansionWrapIndicatorPosition.border,
  });

  /// The children to display.
  final List<Widget> children;

  /// The widget to display when the children are compressed.
  final Widget expandIndicator;

  /// The widget to display when the children are expanded.
  final Widget compressIndicator;

  /// The maximum number of lines to display.
  final int? maxRuns;

  /// The spacing between the children.
  final double spacing;

  /// The spacing between the lines.
  final double runSpacing;

  /// Whether the children are expanded.
  final bool isExpanded;

  /// The position of the indicator.
  final ExpansionWrapIndicatorPosition indicatorPosition;

  @override
  RenderObjectElement createElement() => _ExpansionWrapElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderExpansionWrap(
        maxRuns: maxRuns,
        spacing: spacing,
        runSpacing: runSpacing,
        isExpanded: isExpanded,
        indicatorPosition: indicatorPosition,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderExpansionWrap renderObject,
  ) {
    // print('widget.updateRenderObject');
    super.updateRenderObject(context, renderObject);
    renderObject
      ..maxRuns = maxRuns
      ..spacing = spacing
      ..runSpacing = runSpacing
      ..isExpanded = isExpanded
      ..indicatorPosition = indicatorPosition;
  }
}

class _ExpansionWrapElement extends RenderObjectElement {
  _ExpansionWrapElement(ExpansionWrap super.widget);
  static const int _expandIndicatorSlot = -1;
  static const int _compressIndicatorSlot = -2;

  Element? _expandIndicator;
  Element? _compressIndicator;
  List<Element>? _children;

  @override
  ExpansionWrap get widget => super.widget as ExpansionWrap;

  @override
  RenderExpansionWrap get renderObject =>
      super.renderObject as RenderExpansionWrap;

  @override
  void visitChildren(ElementVisitor visitor) {
    final expandIndicator = _expandIndicator;
    if (expandIndicator != null) visitor(expandIndicator);
    final compressIndicator = _compressIndicator;
    if (compressIndicator != null) visitor(compressIndicator);
    final children = _children;
    if (children != null) {
      children.forEach(visitor);
    }
  }

  Element? _getChild(int slot) {
    if (slot == _expandIndicatorSlot) {
      return _expandIndicator;
    } else if (slot == _compressIndicatorSlot) {
      return _compressIndicator;
    } else {
      final children = _children;
      if (children != null && slot < children.length && slot >= 0) {
        return children[slot];
      }
    }

    return null;
  }

  void _setChild(int slot, Element? value) {
    if (slot == _expandIndicatorSlot) {
      _expandIndicator = value;
    } else if (slot == _compressIndicatorSlot) {
      _compressIndicator = value;
    } else {
      final children = _children;
      if (children != null) {
        if (slot < children.length && slot >= 0) {
          if (value != null) {
            children[slot] = value;
          } else {
            children.removeAt(slot);
          }
        } else if (value != null) {
          children.add(value);
        }
      } else if (value != null) {
        _children = [value];
      }
    }
  }

  @override
  void forgetChild(Element child) {
    final slot = child.slot;
    // print('element.forgetChild at $slot');
    if (slot is int) {
      if (slot == _expandIndicatorSlot) {
        _expandIndicator = null;
      } else if (slot == _compressIndicatorSlot) {
        _compressIndicator = null;
      } else {
        final children = _children;
        if (children != null && slot < children.length && slot >= 0) {
          children.removeAt(slot);
        }
      }
    }
    super.forgetChild(child);
  }

  void _mountChild(Widget? widget, int slot) {
    final Element? oldChild = _getChild(slot);
    final Element? newChild = updateChild(oldChild, widget, slot);
    _setChild(slot, newChild);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    // print('element.mount at $newSlot');
    super.mount(parent, newSlot);
    _mountChild(widget.expandIndicator, _expandIndicatorSlot);
    _mountChild(widget.compressIndicator, _compressIndicatorSlot);
    final widgets = widget.children;
    for (var i = 0; i < widgets.length; i++) {
      _mountChild(widgets[i], i);
    }
  }

  void _updateChild(Widget? widget, int slot) {
    final Element? oldChild = _getChild(slot);
    final Element? newChild = updateChild(oldChild, widget, slot);
    _setChild(slot, newChild);
  }

  @override
  void update(ExpansionWrap newWidget) {
    // print('element.update');
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChild(widget.expandIndicator, _expandIndicatorSlot);
    _updateChild(widget.compressIndicator, _compressIndicatorSlot);
    final widgets = widget.children;
    for (var i = 0; i < widgets.length; i++) {
      _updateChild(widgets[i], i);
    }
    // TODO(RV): remove other children widgets?
  }

  void _updateRenderObject(RenderBox? child, int? slot) {
    if (slot == _expandIndicatorSlot) {
      renderObject.expandIndicator = child;
    } else if (slot == _compressIndicatorSlot) {
      renderObject.compressIndicator = child;
    } else if (slot != null && child != null) {
      renderObject.addWrapChild(child);
    }
  }

  @override
  void insertRenderObjectChild(RenderObject child, dynamic slot) {
    // print('element.insertRenderObjectChild at slot $slot');
    assert(child is RenderBox);
    assert(slot is int);
    _updateRenderObject(child as RenderBox, slot);
  }

  @override
  void removeRenderObjectChild(RenderObject child, dynamic slot) {
    // print('element.removeRenderObjectChild at $slot');
    assert(child is RenderBox);
    _updateRenderObject(null, slot);
  }

  @override
  void moveRenderObjectChild(
    covariant RenderObject child,
    covariant Object? oldSlot,
    covariant Object? newSlot,
  ) {
    // TODO(RV): implement moveRenderObjectChild
    _updateRenderObject(child as RenderBox, 0);
  }
}

class _WrapParentData extends BoxParentData {
  bool _isVisible = true;
}

extension _WrapParentDataExtension on ParentData? {
  set isVisible(bool value) {
    final data = this;
    if (data is _WrapParentData) {
      data._isVisible = value;
    }
  }

  _WrapParentData toWrapParentData() {
    final data = this;
    if (data is _WrapParentData) return data;

    throw Exception('ParentData $data is not a _WrapParentData');
  }
}

/// Renders the children in a wrap layout and adds an indicator at the end if
/// the children do not fit in the available space.
class RenderExpansionWrap extends RenderBox {
  /// Creates a new [RenderExpansionWrap] widget.
  RenderExpansionWrap({
    required int? maxRuns,
    required double spacing,
    required runSpacing,
    required bool isExpanded,
    required ExpansionWrapIndicatorPosition indicatorPosition,
  })  : _maxRuns = maxRuns,
        _spacing = spacing,
        _runSpacing = runSpacing,
        _isExpanded = isExpanded,
        _indicatorPosition = indicatorPosition;

  int? _maxRuns;
  set maxRuns(int? value) {
    if (value == _maxRuns) return;
    _maxRuns = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  double _runSpacing;
  set runSpacing(double value) {
    if (value == _runSpacing) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  bool _isExpanded;
  set isExpanded(bool value) {
    if (value == _isExpanded) return;
    _isExpanded = value;
    markNeedsLayout();
  }

  RenderBox? _expandIndicator;
  set expandIndicator(RenderBox? value) {
    if (value == _expandIndicator) return;
    _updateChild(_expandIndicator, value);
    _expandIndicator = value;
    markNeedsLayout();
  }

  RenderBox? _compressIndicator;
  set compressIndicator(RenderBox? value) {
    if (value == _compressIndicator) return;
    _updateChild(_compressIndicator, value);
    _compressIndicator = value;
    markNeedsLayout();
  }

  ExpansionWrapIndicatorPosition _indicatorPosition =
      ExpansionWrapIndicatorPosition.border;
  set indicatorPosition(ExpansionWrapIndicatorPosition value) {
    if (value == _indicatorPosition) return;
    _indicatorPosition = value;
    markNeedsLayout();
  }

  List<RenderBox>? _wrapChildren;

  /// Adds a child to the end of the children list.
  void addWrapChild(RenderBox child) {
    adoptChild(child);
    _wrapChildren ??= [];
    _wrapChildren?.add(child);
  }

  /// Removes all children from the list.
  void clearWrapChildren() {
    final children = _wrapChildren;
    if (children != null) {
      children.forEach(dropChild);
      _wrapChildren = null;
    }
  }

  void _updateChild(RenderBox? oldChild, RenderBox? newChild) {
    if (oldChild != null) {
      dropChild(oldChild);
    }
    if (newChild != null) {
      adoptChild(newChild);
    }
  }

  // The returned list is ordered for hit testing.
  Iterable<RenderBox> get _allChildren sync* {
    final expandIndicator = _expandIndicator;
    if (expandIndicator != null) yield expandIndicator;
    final compressIndicator = _compressIndicator;
    if (compressIndicator != null) yield compressIndicator;
    final children = _wrapChildren;
    if (children != null) {
      for (final child in children) {
        yield child;
      }
    }
  }

  @override
  void attach(PipelineOwner owner) {
    // print('attach');
    super.attach(owner);
    for (final RenderBox child in _allChildren) {
      child.attach(owner);
    }
  }

  @override
  void detach() {
    // print('detach');
    super.detach();
    for (final RenderBox child in _allChildren) {
      child.detach();
    }
  }

  @override
  void redepthChildren() {
    _allChildren.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _allChildren.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> value = <DiagnosticsNode>[];
    void addDiagnostic(RenderBox? child, String name) {
      if (child != null) value.add(child.toDiagnosticsNode(name: name));
    }

    addDiagnostic(_expandIndicator, 'expandIndicator');
    addDiagnostic(_compressIndicator, 'compressIndicator');
    final children = _wrapChildren;
    if (children != null) {
      for (var i = 0; i < children.length; i++) {
        final child = children[i];
        addDiagnostic(child, 'child $i');
      }
    }

    return value;
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(double height) {
    var min = 0.0;
    for (final child in _allChildren) {
      final minIntrinsic = child.getMinIntrinsicWidth(height);
      if (minIntrinsic > min) {
        min = minIntrinsic;
      }
    }

    return min;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var max = 0.0;
    var addSpacing = false;
    for (final child in _allChildren) {
      if (addSpacing) {
        max += _spacing;
      }
      max += child.getMaxIntrinsicWidth(height);
      addSpacing = true;
    }

    return max;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    var min = 0.0;
    for (final child in _allChildren) {
      final minIntrinsic = child.getMinIntrinsicHeight(width);
      if (minIntrinsic > min) {
        min = minIntrinsic;
      }
    }

    return min;
  }

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(_wrapChildren != null);
    final first = _wrapChildren?.first;
    final parentData = first?.parentData;
    if (first != null && parentData is BoxParentData) {
      return parentData.offset.dy +
          (first.getDistanceToActualBaseline(baseline) ?? 0);
    }

    return 0;
  }

  static Size _layoutBox(RenderBox? box, BoxConstraints constraints) {
    if (box == null) return Size.zero;
    box.layout(constraints, parentUsesSize: true);

    return box.size;
  }

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData = _WrapParentData();
  }

  // All of the dimensions below were taken from the Material Design spec:
  // https://material.io/design/components/lists.html#specs
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final BoxConstraints looseConstraints = constraints.loosen();
    final double availableWidth = looseConstraints.maxWidth;
    final children = _wrapChildren;
    final expanded = _isExpanded;
    final expandIndicator = _expandIndicator;
    final compressIndicator = _compressIndicator;
    if (expanded) {
      if (expandIndicator != null) {
        expandIndicator.parentData.isVisible = false;
      }
    } else if (compressIndicator != null) {
      compressIndicator.parentData.isVisible = false;
    }
    final spacing = _spacing;
    final runSpacing = _runSpacing;
    final compressIndicatorSize =
        _layoutBox(compressIndicator, looseConstraints);
    final expandIndicatorSize = _layoutBox(expandIndicator, looseConstraints);
    final indicator = expanded ? compressIndicator : expandIndicator;
    final indicatorSize =
        expanded ? compressIndicatorSize : expandIndicatorSize;
    final indicatorWith = indicatorSize.width;
    final originalMaxRuns = _maxRuns ?? double.maxFinite.floor();
    final maxRuns = expanded ? double.maxFinite.floor() : originalMaxRuns;

    var currentRunWidth = 0.0;
    var currentRunHeight = 0.0;
    var currentRunY = 0.0;
    var maxRunWidth = 0.0;
    var currentRun = 1;
    var currentRunNumberOfChildren = 0;
    double? crossAxisMaxInCompressedState;
    if (children != null) {
      final lastChildIndex = children.length - 1;
      for (var i = 0; i <= lastChildIndex; i++) {
        final child = children[i];
        final childSize = _layoutBox(child, looseConstraints);
        final parentData = child.parentData.toWrapParentData()
          .._isVisible = currentRun <= maxRuns;
        if (currentRunNumberOfChildren > 0 &&
            ((currentRunWidth + childSize.width > availableWidth) ||
                (currentRun == maxRuns &&
                    (currentRunWidth +
                            childSize.width +
                            spacing +
                            indicatorWith >
                        availableWidth)) ||
                (i == lastChildIndex &&
                    (currentRunWidth +
                            childSize.width +
                            spacing +
                            indicatorWith >
                        availableWidth)))) {
          // line break: move current child to next row:
          if (currentRun == maxRuns &&
              currentRunWidth + spacing + indicatorWith > maxRunWidth) {
            maxRunWidth = currentRunWidth + spacing + indicatorWith;
          } else if (currentRunWidth > maxRunWidth) {
            maxRunWidth = currentRunWidth;
          }
          if (currentRun == maxRuns) {
            parentData._isVisible = false;
            if (indicator != null) {
              // this is the last visible run, add indicator:
              final indicatorParentData =
                  indicator.parentData.toWrapParentData().._isVisible = true;
              final dx =
                  _indicatorPosition == ExpansionWrapIndicatorPosition.border
                      ? availableWidth - indicatorWith
                      : currentRunWidth + spacing;
              indicatorParentData.offset = Offset(
                dx,
                currentRunY + (currentRunHeight - indicatorSize.height) / 2,
              );
            }
            crossAxisMaxInCompressedState =
                currentRunY + currentRunHeight + runSpacing;
          }
          currentRunY += currentRunHeight + runSpacing;
          currentRunWidth = 0.0;
          currentRunHeight = 0.0;
          currentRunNumberOfChildren = 0;
          currentRun++;
        }
        parentData.offset = Offset(currentRunWidth + spacing, currentRunY);
        if (childSize.height > currentRunHeight) {
          currentRunHeight = childSize.height;
        }
        currentRunNumberOfChildren++;
        currentRunWidth += childSize.width + spacing;
      }
    }
    if (_indicatorPosition == ExpansionWrapIndicatorPosition.border) {
      maxRunWidth = availableWidth;
    }
    if (expanded && currentRun >= originalMaxRuns && indicator != null) {
      // add compress indicator at the end:
      final indicatorParentData = indicator.parentData.toWrapParentData()
        .._isVisible = true;
      final dx = _indicatorPosition == ExpansionWrapIndicatorPosition.border
          ? availableWidth - indicatorWith
          : currentRunWidth + spacing;
      indicatorParentData.offset = Offset(
        dx,
        currentRunY + (currentRunHeight - indicatorSize.height) / 2,
      );
    }
    if (!expanded && currentRun <= originalMaxRuns && indicator != null) {
      indicator.parentData.isVisible = false;
    }
    size = crossAxisMaxInCompressedState != null
        ? constraints
            .constrain(Size(maxRunWidth, crossAxisMaxInCompressedState))
        : constraints
            .constrain(Size(maxRunWidth, currentRunY + currentRunHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void doPaint(RenderBox? child) {
      if (child != null) {
        final parentData = child.parentData;
        if (parentData is _WrapParentData && parentData._isVisible) {
          context.paintChild(child, parentData.offset + offset);
        }
      }
    }

    final children = _wrapChildren;
    if (children != null) {
      children.forEach(doPaint);
    }
    doPaint(_expandIndicator);
    doPaint(_compressIndicator);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final RenderBox child in _allChildren) {
      final parentData = child.parentData;
      final bool isHit = parentData is _WrapParentData &&
          parentData._isVisible &&
          result.addWithPaintOffset(
            offset: parentData.offset,
            position: position,
            hitTest: (BoxHitTestResult result, Offset transformed) {
              assert(transformed == position - parentData.offset);

              return child.hitTest(result, position: transformed);
            },
          );
      if (isHit) return true;
    }

    return false;
  }
}
