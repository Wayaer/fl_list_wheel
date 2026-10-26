part of 'picker.dart';

extension FlSingleListWheelPickerExtension on FlSingleListWheelPicker {
  /// 打开选择器弹窗并返回选中的下标，取消时返回 null
  Future<int?> show({FlPickerPresenter? presenter}) => FlListWheel.showPicker<int>(this, presenter: presenter);
}

/// 滚动结束回调，参数为当前选中的下标
typedef FlSingleListWheelPickerChanged = void Function(int index);

/// 单列滚轮选择器：使用一列滚轮选择单个下标。
class FlSingleListWheelPicker extends FlPickerStatefulWidget<int> {
  const FlSingleListWheelPicker({
    super.key,
    super.options,
    super.wheelOptions,
    super.height = kPickerDefaultHeight,
    super.width = double.infinity,
    super.itemWidth,
    this.initialIndex = 0,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.onChanged,
  });

  /// 初始选中下标，超出 [itemCount] 范围时自动收敛到边界；变化时会自动滚动到对应位置
  final int initialIndex;

  /// 子项数量；为 0 时没有可选项，确认结果按取消处理（返回 null）
  final int itemCount;

  /// 按 index 渲染子项
  final IndexedWidgetBuilder itemBuilder;

  /// 外部滚动控制器；为 null 时组件自动创建并负责销毁
  final FixedExtentScrollController? controller;

  /// 滚动结束回调
  final FlSingleListWheelPickerChanged? onChanged;

  @override
  State<FlSingleListWheelPicker> createState() => _FlSingleListWheelPickerState();
}

class _FlSingleListWheelPickerState extends State<FlSingleListWheelPicker> {
  /// 内部自动创建的 controller，由 FlListWheelState 负责销毁；外部传入 [FlSingleListWheelPicker.controller] 时为 null
  FixedExtentScrollController? _ownedController;

  int get _maxItem => widget.itemCount > 0 ? widget.itemCount - 1 : 0;

  /// 初始下标按 itemCount 做边界校正，避免越界
  int get _safeInitialIndex {
    final int index = widget.initialIndex;
    if (index <= 0) return 0;
    return index > _maxItem ? _maxItem : index;
  }

  /// 当前选中的下标；没有可选项时返回 null（确认结果按取消处理）
  int? _selectedIndex() {
    if (widget.itemCount == 0) return null;
    final FixedExtentScrollController? controller = widget.controller ?? _ownedController;
    if (controller == null || !controller.hasClients) return _safeInitialIndex;
    return controller.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    Widget wheel = FlListWheelState(
      initialItem: _safeInitialIndex,
      controller: widget.controller,
      count: widget.itemCount,
      onCreateController: (FixedExtentScrollController controller) => _ownedController = controller,
      builder: (FixedExtentScrollController controller) => _FlPickerListWheel(
        controller: controller,
        options: widget.wheelOptions,
        itemBuilder: widget.itemBuilder,
        itemCount: widget.itemCount,
        onChanged: (_) {},
        onScrollEnd: widget.onChanged,
      ),
    );
    final double? itemWidth = widget.itemWidth;
    if (itemWidth != null) {
      wheel = Center(
        child: SizedBox(width: itemWidth, child: wheel),
      );
    }
    final Widget single = SizedBox(width: widget.width, height: widget.height, child: wheel);
    return _buildPicker<int>(options: widget.options, child: single, confirmTap: _selectedIndex);
  }
}
