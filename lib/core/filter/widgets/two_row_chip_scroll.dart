import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';

/// Area chip dua baris yang digeser horizontal bersama.
/// Separuh pertama chip (ceil(n/2)) di baris atas, sisanya di baris bawah.
/// Jika hanya 1 chip, tampil satu baris.
class TwoRowChipScroll extends StatefulWidget {
  const TwoRowChipScroll({
    super.key,
    required this.children,
    this.initialFocusIndex,
  });

  final List<Widget> children;
  final int? initialFocusIndex;

  @override
  State<TwoRowChipScroll> createState() => _TwoRowChipScrollState();
}

class _TwoRowChipScrollState extends State<TwoRowChipScroll> {
  final ScrollController _controller = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  final Map<int, GlobalKey> _chipKeys = <int, GlobalKey>{};
  bool _didAutoScroll = false;
  int _autoScrollAttempts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_scrollToInitialFocus);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GlobalKey _chipKey(int index) =>
      _chipKeys.putIfAbsent(index, () => GlobalKey());

  void _scrollToInitialFocus(Duration _) {
    if (_didAutoScroll || !mounted) {
      return;
    }

    final int? index = widget.initialFocusIndex;
    if (index == null || index < 0 || index >= widget.children.length) {
      _didAutoScroll = true;
      return;
    }

    if (!_controller.hasClients) {
      _autoScrollAttempts++;
      if (_autoScrollAttempts <= 5) {
        WidgetsBinding.instance.addPostFrameCallback(_scrollToInitialFocus);
      }
      return;
    }

    final BuildContext? chipContext = _chipKeys[index]?.currentContext;
    final BuildContext? viewportContext = _viewportKey.currentContext;
    final RenderObject? chipRender = chipContext?.findRenderObject();
    final RenderObject? viewportRender = viewportContext?.findRenderObject();
    if (chipRender is! RenderBox ||
        viewportRender is! RenderBox ||
        !chipRender.hasSize ||
        !viewportRender.hasSize) {
      _autoScrollAttempts++;
      if (_autoScrollAttempts <= 5) {
        WidgetsBinding.instance.addPostFrameCallback(_scrollToInitialFocus);
      } else {
        _didAutoScroll = true;
      }
      return;
    }

    _didAutoScroll = true;

    const double inset = AppDimensions.filterSheetPadding;
    final double chipLeft = chipRender
        .localToGlobal(Offset.zero, ancestor: viewportRender)
        .dx;
    final double chipRight = chipLeft + chipRender.size.width;
    final double viewportWidth = viewportRender.size.width;

    if (chipLeft >= inset && chipRight <= viewportWidth - inset) {
      return;
    }

    final double target = (_controller.offset + chipLeft - inset).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    if ((target - _controller.offset).abs() < 0.5) {
      return;
    }
    _controller.jumpTo(target);
  }

  List<Widget> _buildRowChildren(List<int> indices) {
    final List<Widget> rowChildren = <Widget>[];
    for (int i = 0; i < indices.length; i++) {
      if (i > 0) {
        rowChildren.add(const SizedBox(width: AppDimensions.chipSpacing));
      }
      final int index = indices[i];
      rowChildren.add(
        KeyedSubtree(key: _chipKey(index), child: widget.children[index]),
      );
    }
    return rowChildren;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final int count = widget.children.length;
    final int topCount = count <= 1 ? count : (count + 1) ~/ 2;
    final List<int> topIndices = List<int>.generate(topCount, (int i) => i);
    final List<int> bottomIndices = List<int>.generate(
      count - topCount,
      (int i) => topCount + i,
    );

    return SizedBox(
      height: AppDimensions.filterSheetChipAreaHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: <PointerDeviceKind>{
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
            PointerDeviceKind.invertedStylus,
            PointerDeviceKind.unknown,
          },
        ),
        child: SingleChildScrollView(
          key: _viewportKey,
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.filterSheetPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: AppDimensions.filterSheetChipRowHeight,
                  child: Row(children: _buildRowChildren(topIndices)),
                ),
                if (bottomIndices.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppDimensions.filterSheetChipRowGap),
                  SizedBox(
                    height: AppDimensions.filterSheetChipRowHeight,
                    child: Row(children: _buildRowChildren(bottomIndices)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
