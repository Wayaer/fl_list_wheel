import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/cupertino.dart';

typedef FlListWheelPushCallback = Future<dynamic> Function(Widget picker);

typedef FlListWheelPopCallback = void Function(dynamic value);

typedef FlListWheelValueChanged = void Function(int index);

class FlListWheel extends StatelessWidget {
  /// 设置全局 [FlListWheel] 配置
  /// Set the global [FlListWheel] configuration
  static WheelOptions wheelOptions = const WheelOptions.cupertino();

  /// push
  static FlListWheelPushCallback? push;

  /// get push
  static FlListWheelPushCallback get pushFun {
    assert(push != null, 'You must first assign a value to "push"');
    return push!;
  }

  /// pop
  static FlListWheelPopCallback? pop;

  /// get pop
  static FlListWheelPopCallback get popFun {
    assert(pop != null, 'You must first assign a value to "pop"');
    return pop!;
  }

  const FlListWheel({
    super.key,
    required this.delegate,
    this.controller,
    this.onScrollEnd,
    this.onNotification,
    this.onScrollStart,
    this.onScrollUpdate,
    this.options,
    required this.onSelectedItemChanged,
  });

  FlListWheel.builder({
    super.key,
    required NullableIndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.controller,
    this.onScrollEnd,
    this.onNotification,
    this.onScrollStart,
    this.onScrollUpdate,
    this.options,
    required this.onSelectedItemChanged,
  }) : delegate = ListWheelChildBuilderDelegate(
            builder: itemBuilder, childCount: itemCount);

  FlListWheel.count({
    super.key,
    required List<Widget> children,
    this.controller,
    this.onScrollEnd,
    this.onNotification,
    this.onScrollStart,
    this.onScrollUpdate,
    this.options,
    bool looping = false,
    required this.onSelectedItemChanged,
  }) : delegate = looping
            ? ListWheelChildLoopingListDelegate(children: children)
            : ListWheelChildListDelegate(children: children);

  final ListWheelChildDelegate delegate;

  final WheelOptions? options;

  /// 控制器
  final FixedExtentScrollController? controller;

  /// 回调监听
  final FlListWheelValueChanged? onSelectedItemChanged;

  /// 滚动监听 添加此方法  [onScrollStart],[onScrollUpdate],[onScrollEnd] 无效
  final NotificationListenerCallback<ScrollNotification>? onNotification;

  /// 滚动开始回调
  final FlListWheelValueChanged? onScrollStart;

  /// 滚动中回调
  final FlListWheelValueChanged? onScrollUpdate;

  /// 滚动结束回调
  final FlListWheelValueChanged? onScrollEnd;

  @override
  Widget build(BuildContext context) {
    final wheelOptions = FlListWheel.wheelOptions.merge(options);
    Widget child;
    if (wheelOptions.isCupertino) {
      child = CupertinoListWheelScrollView.useDelegate(
          scrollController: controller,
          delegate: delegate,
          onSelectedItemChanged: onSelectedItemChanged,
          diameterRatio: wheelOptions.diameterRatio,
          backgroundColor: wheelOptions.backgroundColor,
          offAxisFraction: wheelOptions.offAxisFraction,
          useMagnifier: wheelOptions.useMagnifier,
          magnification: wheelOptions.magnification,
          squeeze: wheelOptions.squeeze,
          itemExtent: wheelOptions.itemExtent,
          selectionOverlay: wheelOptions.selectionOverlay);
    } else {
      child = ListWheelScrollView.useDelegate(
          controller: controller,
          childDelegate: delegate,
          itemExtent: wheelOptions.itemExtent,
          physics: wheelOptions.physics,
          diameterRatio: wheelOptions.diameterRatio,
          onSelectedItemChanged: onSelectedItemChanged,
          offAxisFraction: wheelOptions.offAxisFraction,
          perspective: wheelOptions.perspective,
          useMagnifier: wheelOptions.useMagnifier,
          squeeze: wheelOptions.squeeze,
          magnification: wheelOptions.magnification,
          renderChildrenOutsideViewport:
              wheelOptions.renderChildrenOutsideViewport,
          overAndUnderCenterOpacity: wheelOptions.overAndUnderCenterOpacity,
          clipBehavior: wheelOptions.clipBehavior,
          restorationId: wheelOptions.restorationId,
          scrollBehavior: wheelOptions.scrollBehavior);
    }
    if (onNotification != null ||
        onScrollStart != null ||
        onScrollUpdate != null ||
        onScrollEnd != null) {
      return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            onNotification?.call(notification);
            if (notification is ScrollStartNotification &&
                onScrollStart != null) {
              onScrollStart!(controller?.selectedItem ?? 0);
            } else if (notification is ScrollUpdateNotification &&
                onScrollUpdate != null) {
              onScrollUpdate!(controller?.selectedItem ?? 0);
            } else if (notification is ScrollEndNotification &&
                onScrollEnd != null) {
              onScrollEnd!(controller?.selectedItem ?? 0);
            }
            return false;
          },
          child: child);
    }
    return child;
  }
}

typedef FlListWheelStateBuilder = FlListWheel Function(
    FixedExtentScrollController controller);

typedef FlListWheelStateOnScrollController = void Function(
    FixedExtentScrollController controller);

/// 解决父组件重新 build 时 改变子元素长度后显示异常问题
/// 添加支持初始位置
class FlListWheelState extends StatefulWidget {
  const FlListWheelState(
      {super.key,
      this.initialItem = 0,
      this.controller,
      this.disposeController = true,
      this.animateDuration = const Duration(milliseconds: 10),
      this.curve = Curves.linear,
      this.onCreateController,
      required this.count,
      required this.builder});

  /// 默认为 true 组件 dispose 自动调用 controller.dispose()
  final bool disposeController;

  /// 条目数量
  final int count;

  /// 初始item
  final int initialItem;

  /// 控制器
  final FixedExtentScrollController? controller;

  /// [controller] 为null  自动创建 controller 回调
  final FlListWheelStateOnScrollController? onCreateController;

  /// animateToItem
  final Duration animateDuration;

  /// curve
  final Curve curve;

  final FlListWheelStateBuilder builder;

  @override
  State<FlListWheelState> createState() => _FlListWheelStateState();
}

class _FlListWheelStateState extends State<FlListWheelState> {
  late FixedExtentScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        FixedExtentScrollController(initialItem: initialItem);
    if (widget.controller == null) widget.onCreateController?.call(controller);
  }

  int get initialItem =>
      widget.initialItem > widget.count ? widget.count : widget.initialItem;

  @override
  Widget build(BuildContext context) => widget.builder(controller);

  @override
  void didUpdateWidget(covariant FlListWheelState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && controller != widget.controller) {
      controller.dispose();
      controller = widget.controller!;
    }
    if (controller.selectedItem > widget.count ||
        controller.selectedItem != widget.initialItem) {
      controller.animateToItem(initialItem,
          duration: widget.animateDuration, curve: widget.curve);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.disposeController) controller.dispose();
  }
}

class CupertinoListWheelScrollView extends CupertinoPicker {
  CupertinoListWheelScrollView.useDelegate({
    super.key,
    required super.itemExtent,
    required super.onSelectedItemChanged,
    required this.delegate,
    super.backgroundColor,
    super.diameterRatio,
    super.magnification,
    super.offAxisFraction,
    super.scrollController,
    super.selectionOverlay,
    super.squeeze,
    super.useMagnifier,
  }) : super(children: []);

  final ListWheelChildDelegate delegate;

  @override
  ListWheelChildDelegate get childDelegate => delegate;
}
