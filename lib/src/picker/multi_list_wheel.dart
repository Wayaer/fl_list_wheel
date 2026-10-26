part of 'picker.dart';

extension FlMultiListWheelPickerExtension on FlMultiListWheelPicker {
  /// 打开选择器弹窗并返回每一列选中的下标，取消时返回 null
  Future<List<int>?> show({FlPickerPresenter? presenter}) =>
      FlListWheel.showPicker<List<int>>(this, presenter: presenter);
}

/// 一列滚轮的数据与渲染方式
class FlPickerItem {
  const FlPickerItem({required this.itemCount, required this.itemBuilder});

  /// 该列的子项数量
  final int itemCount;

  /// 按 index 渲染该列的子项
  final IndexedWidgetBuilder itemBuilder;
}

/// 多列滚轮选择（各列互不联动）。
/// 任一列没有可选项时，确认结果按取消处理（返回 null）。
class FlMultiListWheelPicker extends FlPickerStatefulWidget<List<int>> {
  const FlMultiListWheelPicker({
    super.key,
    super.height = kPickerDefaultHeight,
    super.width = double.infinity,
    super.itemWidth,
    super.options,
    super.wheelOptions,
    required this.items,
    this.isScrollable = false,
    this.onChanged,
    this.value = const [],
  });

  /// 每一列的数据
  final List<FlPickerItem> items;

  /// 每一列的初始选中下标
  final List<int> value;

  /// 是否横向滚动：true 时每列宽度为 [itemWidth] 或默认宽度；false 时各列均分宽度
  final bool isScrollable;

  /// 某一列滚动结束时触发，参数为所有列当前的下标
  final FlPickerPositionIndexChanged? onChanged;

  @override
  State<FlMultiListWheelPicker> createState() => _FlMultiListWheelPickerState();
}

class _FlMultiListWheelPickerState extends State<FlMultiListWheelPicker> {
  /// 当前每列选中的下标，交互过程中由 Wheel 实时更新
  late List<int> position;

  final _FlPickerPositionTracker tracker = _FlPickerPositionTracker();

  @override
  void initState() {
    super.initState();
    position = _initialPosition();
  }

  List<int> _initialPosition() => _clampPosition(widget.value);

  /// 按当前列的数据量校正下标，避免越界
  List<int> _clampPosition(List<int> raw) {
    final List<int> result = [];
    for (int i = 0; i < widget.items.length; i++) {
      final int count = widget.items[i].itemCount;
      final int value = i < raw.length ? raw[i] : 0;
      result.add(count <= 0 ? 0 : (value < 0 ? 0 : (value >= count ? count - 1 : value)));
    }
    return result;
  }

  @override
  void didUpdateWidget(covariant FlMultiListWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_equalsList(oldWidget.value, widget.value) || oldWidget.items.length != widget.items.length) {
      position = _initialPosition();
    } else {
      position = _clampPosition(position);
    }
  }

  void onChanged() {
    final List<int> current = [...position];
    if (!tracker.isChanged(current)) return;
    widget.onChanged?.call(current);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    for (int i = 0; i < widget.items.length; i++) {
      final FlPickerItem item = widget.items[i];
      final int count = item.itemCount;
      final int value = position[i] >= count ? (count > 0 ? count - 1 : 0) : position[i];
      children.add(
        FlListWheelState(
          key: ValueKey<int>(i),
          initialItem: value,
          count: item.itemCount,
          builder: (controller) => _FlPickerListWheel(
            controller: controller,
            options: widget.wheelOptions,
            itemBuilder: item.itemBuilder,
            itemCount: item.itemCount,
            onChanged: (int index) => position[i] = index,
            onScrollEnd: (_) => onChanged(),
          ),
        ),
      );
    }
    final Widget current = _FlPickerColumnLayout(
      columns: children,
      width: widget.width,
      height: widget.height,
      isScrollable: widget.isScrollable,
      itemWidth: widget.itemWidth,
    );
    return _buildPicker<List<int>>(
      options: widget.options,
      child: current,
      // 任一列没有可选项时无法给出有效下标，按取消处理
      confirmTap: () => widget.items.any((FlPickerItem item) => item.itemCount == 0) ? null : [...position],
    );
  }
}

/// 滚轮联动选择的一项
class FlPickerLinkageItem<T> {
  const FlPickerLinkageItem({required this.value, required this.child, this.children = const []});

  /// 该项的显示内容
  final Widget child;

  /// 该项对应的业务值
  final T value;

  /// 下一级选项
  final List<FlPickerLinkageItem<T>> children;
}

extension FlMultiListWheelLinkagePickerExtension on FlMultiListWheelLinkagePicker {
  /// 打开选择器弹窗并返回选中的下标路径，取消时返回 null
  Future<List<int>?> show({FlPickerPresenter? presenter}) =>
      FlListWheel.showPicker<List<int>>(this, presenter: presenter);
}

/// 多列滚轮联动选择：选中某一列后，后面各列自动切换为该选项的 [FlPickerLinkageItem.children]。
class FlMultiListWheelLinkagePicker<T> extends FlPickerStatefulWidget<List<int>> {
  const FlMultiListWheelLinkagePicker({
    super.key,
    super.height = kPickerDefaultHeight,
    super.width = double.infinity,
    super.itemWidth,
    super.options,
    super.wheelOptions,
    required this.items,
    this.value = const [],
    this.isScrollable = false,
    this.onChanged,
    this.onValueChanged,
  });

  /// 要渲染的层级数据
  final List<FlPickerLinkageItem<T>> items;

  /// 是否横向滚动：true 时每列宽度为 [itemWidth] 或默认宽度；false 时各列均分宽度
  final bool isScrollable;

  /// 初始选中的下标路径
  final List<int> value;

  /// 选择下标变化回调
  final FlPickerPositionIndexChanged? onChanged;

  /// 选择内容变化回调
  final FlPickerPositionValueChanged<T>? onValueChanged;

  @override
  State<FlMultiListWheelLinkagePicker<T>> createState() => _FlMultiListWheelLinkagePickerState<T>();
}

class _FlMultiListWheelLinkagePickerState<T> extends State<FlMultiListWheelLinkagePicker<T>> {
  late List<FlPickerLinkageItem<T>> items;

  late List<int> position;

  final _FlPickerPositionTracker tracker = _FlPickerPositionTracker();

  @override
  void initState() {
    super.initState();
    items = widget.items;
    position = _resolve(widget.value);
  }

  @override
  void didUpdateWidget(covariant FlMultiListWheelLinkagePicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    items = widget.items;
    if (!_equalsList(oldWidget.value, widget.value)) {
      position = _resolve(widget.value);
    } else if (!identical(oldWidget.items, widget.items)) {
      position = _resolve(position);
    }
  }

  /// 校正当前下标并补齐所有层级的默认值，保证 build 期间不修改状态
  List<int> _resolve(List<int> raw) {
    final List<int> result = [];
    List<FlPickerLinkageItem<T>> currentEntry = items;
    for (int i = 0; i < raw.length && currentEntry.isNotEmpty; i++) {
      final int value = raw[i];
      final int index = value < 0 ? 0 : (value >= currentEntry.length ? currentEntry.length - 1 : value);
      result.add(index);
      currentEntry = currentEntry[index].children;
    }
    while (currentEntry.isNotEmpty) {
      result.add(0);
      currentEntry = currentEntry.first.children;
    }
    return result;
  }

  /// 修改某一级选择，并重置该级之后的所有选择
  void _select(int location, int index) {
    if (position[location] == index) return;
    position[location] = index;
    for (int i = location + 1; i < position.length; i++) {
      position[i] = 0;
    }
    position = _resolve(position);
  }

  List<Widget> get buildWheels {
    final List<Widget> list = [];
    List<FlPickerLinkageItem<T>> itemsList = items;
    for (int i = 0; i < position.length && itemsList.isNotEmpty; i++) {
      final int raw = position[i];
      final int index = raw < 0 ? 0 : (raw >= itemsList.length ? itemsList.length - 1 : raw);
      list.add(listStateWheel(key: ValueKey<int>(i), list: itemsList, location: i));
      itemsList = itemsList[index].children;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final Widget current = _FlPickerColumnLayout(
      columns: buildWheels,
      width: widget.width,
      height: widget.height,
      isScrollable: widget.isScrollable,
      itemWidth: widget.itemWidth,
    );
    return _buildPicker<List<int>>(options: widget.options, child: current, confirmTap: () => calculatePosition);
  }

  List<int> get calculatePosition => [...position];

  void onChanged() {
    final List<int> p = calculatePosition;
    if (!tracker.isChanged(p)) return;
    widget.onChanged?.call(p);
    if (widget.onValueChanged == null) return;
    final List<T> value = [];
    List<FlPickerLinkageItem<T>> resultList = items;
    for (final int index in p) {
      if (index >= resultList.length) break;
      value.add(resultList[index].value);
      resultList = resultList[index].children;
    }
    widget.onValueChanged!(value);
  }

  Widget listStateWheel({Key? key, required List<FlPickerLinkageItem<T>> list, required int location}) =>
      FlListWheelState(
        key: key,
        count: list.length,
        initialItem: position[location],
        builder: (controller) => _FlPickerListWheel(
          controller: controller,
          onChanged: (int index) => _select(location, index),
          onScrollEnd: (int index) {
            // 先同步通知外部，保证确认按钮能立刻拿到本次滚动结果
            onChanged();
            final bool hasChildren = list.length > index && list[index].children.isNotEmpty;
            if (location < position.length - 1 || hasChildren) {
              // 等当前帧结束后再重建后续列，避免在滚动通知回调中直接 setState
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
            }
          },
          itemBuilder: (_, int index) => Center(child: list[index].child),
          itemCount: list.length,
          options: widget.wheelOptions,
        ),
      );
}
