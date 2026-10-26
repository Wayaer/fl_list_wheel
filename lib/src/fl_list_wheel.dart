import 'package:fl_list_wheel/src/options.dart';
import 'package:fl_list_wheel/src/presentation.dart';
import 'package:flutter/cupertino.dart';

/// 滚轮位置变化回调，参数为变化后的下标
typedef FlListWheelValueChanged = void Function(int index);

/// 通用单列滚轮。
/// 封装 [ListWheelScrollView] 与 [CupertinoPicker]，通过 [options] 切换样式；
/// 同时持有全局的 [presenter]，供各 Picker 打开弹窗。
class FlListWheel extends StatelessWidget {
  /// 全局滚轮配置，单个滚轮可通过 [options] 覆盖
  static FlWheelOptions wheelOptions = const FlWheelOptions.cupertino();

  /// 全局选择器展示器，调用任意 Picker 的 show() 前必须赋值。
  /// 作用于整个应用进程，页面退出登录等场景可通过 [reset] 清空。
  static FlPickerPresenter? presenter;

  /// 重置全局配置：[wheelOptions] 恢复为默认 Cupertino 风格，[presenter] 置空
  static void reset() {
    wheelOptions = const FlWheelOptions.cupertino();
    presenter = null;
  }

  /// 打开选择器并等待结果；所有 Picker 的 show() 最终都会调用这里。
  /// [presenter] 优先于全局 [FlListWheel.presenter]，可用于单次指定展示方式。
  /// 未配置 presenter 时返回的 Future 会抛出 [FlutterError]。
  static Future<T?> showPicker<T>(Widget picker, {FlPickerPresenter? presenter}) async {
    final FlPickerPresenter? current = presenter ?? FlListWheel.presenter;
    if (current == null) {
      throw FlutterError(
        'No FlPickerPresenter configured. Assign FlListWheel.presenter = '
        'FlBottomSheetPickerPresenter(context: () => navigatorKey.currentContext!) '
        'before calling show().',
      );
    }
    return current.show<T>(picker);
  }

  /// 使用自定义 [ListWheelChildDelegate] 构建子项
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

  /// 通过 [itemBuilder] 按需构建子项，适合数据量较大的场景
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
  }) : delegate = ListWheelChildBuilderDelegate(builder: itemBuilder, childCount: itemCount);

  /// 使用固定的 [children] 列表构建子项；[looping] 为 true 时可无限循环滚动
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

  /// 滚轮子项的构建委托，决定每一项如何渲染
  final ListWheelChildDelegate delegate;

  /// 单个滚轮的样式与滚动参数，未设置时使用全局 [wheelOptions]。
  /// 注意：[FlWheelOptions.isCupertino] 始终以全局配置为准，此处设置不会切换渲染风格。
  final FlWheelOptions? options;

  /// 滚动控制器，用于代码控制选中位置
  final FixedExtentScrollController? controller;

  /// 选中项变化回调
  final FlListWheelValueChanged? onSelectedItemChanged;

  /// 原生滚动通知监听；设置后 [onScrollStart]/[onScrollUpdate]/[onScrollEnd] 不再触发
  final NotificationListenerCallback<ScrollNotification>? onNotification;

  /// 滚动开始回调，参数为当前下标
  final FlListWheelValueChanged? onScrollStart;

  /// 滚动进行中回调，参数为当前下标
  final FlListWheelValueChanged? onScrollUpdate;

  /// 滚动结束回调，参数为当前下标
  final FlListWheelValueChanged? onScrollEnd;

  @override
  Widget build(BuildContext context) {
    final FlWheelOptions wheelOptions = FlListWheel.wheelOptions.merge(options);
    Widget child;
    if (wheelOptions.isCupertino) {
      child = FlCupertinoListWheelScrollView.useDelegate(
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
        selectionOverlay: wheelOptions.selectionOverlay,
      );
    } else {
      child = ListWheelScrollView.useDelegate(
        controller: controller,
        childDelegate: delegate,
        itemExtent: wheelOptions.itemExtent,
        physics: wheelOptions.physics ?? const FixedExtentScrollPhysics(),
        diameterRatio: wheelOptions.diameterRatio,
        onSelectedItemChanged: onSelectedItemChanged,
        offAxisFraction: wheelOptions.offAxisFraction,
        perspective: wheelOptions.perspective,
        useMagnifier: wheelOptions.useMagnifier,
        squeeze: wheelOptions.squeeze,
        magnification: wheelOptions.magnification,
        renderChildrenOutsideViewport: wheelOptions.renderChildrenOutsideViewport,
        overAndUnderCenterOpacity: wheelOptions.overAndUnderCenterOpacity,
        clipBehavior: wheelOptions.clipBehavior,
        restorationId: wheelOptions.restorationId,
        scrollBehavior: wheelOptions.scrollBehavior,
      );
    }
    if (onNotification == null && onScrollStart == null && onScrollUpdate == null && onScrollEnd == null) {
      return child;
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (onNotification != null) {
          // 返回值交给调用方决定，true 表示不再向上冒泡
          return onNotification!.call(notification);
        }
        final int index = _itemIndexOf(notification);
        if (notification is ScrollStartNotification) {
          onScrollStart?.call(index);
        } else if (notification is ScrollUpdateNotification) {
          onScrollUpdate?.call(index);
        } else if (notification is ScrollEndNotification) {
          onScrollEnd?.call(index);
        }
        return false;
      },
      child: child,
    );
  }

  int _itemIndexOf(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics is FixedExtentMetrics) return metrics.itemIndex;
    return controller?.selectedItem ?? 0;
  }
}

typedef FlListWheelStateBuilder = FlListWheel Function(FixedExtentScrollController controller);

typedef FlListWheelStateOnScrollController = void Function(FixedExtentScrollController controller);

/// 带状态管理的滚轮容器。
/// 解决父组件重建、子项数量变化后滚轮显示异常的问题，并支持指定初始选中项。
class FlListWheelState extends StatefulWidget {
  const FlListWheelState({
    super.key,
    this.initialItem = 0,
    this.controller,
    this.disposeController = true,
    this.animateDuration = const Duration(milliseconds: 10),
    this.curve = Curves.linear,
    this.onCreateController,
    required this.count,
    required this.builder,
  });

  /// 是否由组件负责销毁自动创建的 controller。
  /// 为 false 时 controller 的销毁责任交给调用方；
  /// 若 controller 是组件自动创建的，设置 false 后需自行通过 [onCreateController] 拿到并销毁，否则会泄漏。
  /// 外部传入的 controller 始终不会被销毁。
  final bool disposeController;

  /// 子项总数量
  final int count;

  /// 初始选中下标，内部会按 [count] 做边界校正
  final int initialItem;

  /// 外部滚动控制器；为 null 时组件自动创建
  final FixedExtentScrollController? controller;

  /// 组件自动创建 controller 后的回调，可直接保存并复用
  final FlListWheelStateOnScrollController? onCreateController;

  /// [initialItem] 变化时滚动到目标位置的动画时长
  final Duration animateDuration;

  /// 滚动动画曲线
  final Curve curve;

  /// 使用 controller 构建实际滚轮的 builder
  final FlListWheelStateBuilder builder;

  @override
  State<FlListWheelState> createState() => _FlListWheelStateState();
}

class _FlListWheelStateState extends State<FlListWheelState> {
  late FixedExtentScrollController controller;

  /// 是否由本组件创建并负责销毁 controller
  bool _ownsController = false;

  int get maxItem => widget.count > 0 ? widget.count - 1 : 0;

  int get initialItem {
    final int item = widget.initialItem;
    if (item <= 0) return 0;
    return item > maxItem ? maxItem : item;
  }

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  void _attachController() {
    final FixedExtentScrollController? external = widget.controller;
    _ownsController = external == null;
    controller = external ?? FixedExtentScrollController(initialItem: initialItem);
    if (_ownsController) widget.onCreateController?.call(controller);
  }

  void _detachController() {
    if (!_ownsController || !widget.disposeController) return;
    controller.dispose();
    _ownsController = false;
  }

  @override
  void didUpdateWidget(covariant FlListWheelState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController();
      return;
    }
    final bool initialChanged = oldWidget.initialItem != widget.initialItem;
    final bool hasClients = controller.hasClients;
    final bool countShrunk = hasClients && controller.selectedItem > maxItem;
    if (!initialChanged && !countShrunk) return;
    final int target = initialChanged ? initialItem : maxItem;
    if (hasClients) {
      if (controller.selectedItem != target) {
        controller.animateToItem(target, duration: widget.animateDuration, curve: widget.curve);
      }
      return;
    }
    // controller 还未附着时等本次布局完成后再定位，保证 initialItem 变化能生效
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) return;
      if (controller.selectedItem != target) controller.jumpToItem(target);
    });
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(controller);
}

/// 让 [CupertinoPicker] 支持 [ListWheelChildDelegate] 的适配器
class FlCupertinoListWheelScrollView extends CupertinoPicker {
  FlCupertinoListWheelScrollView.useDelegate({
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
