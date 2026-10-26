part of 'picker.dart';

/// 根据是否选中构建列表项的外观
typedef FlPickerListLinkageItemBuilder = Widget Function(bool selected);

extension FlMultiListLinkagePickerExtension on FlMultiListLinkagePicker {
  /// 打开选择器弹窗并返回选中的下标路径，取消时返回 null
  Future<List<int>?> show({FlPickerPresenter? presenter}) =>
      FlListWheel.showPicker<List<int>>(this, presenter: presenter);
}

/// 列表联动选择的一项
class FlPickerListLinkageItem<T> {
  const FlPickerListLinkageItem({required this.value, required this.child, this.children = const []});

  /// 根据选中状态构建该项外观
  final FlPickerListLinkageItemBuilder child;

  /// 该项对应的业务值
  final T value;

  /// 下一级选项列表
  final List<FlPickerListLinkageItem<T>> children;
}

/// 多列列表联动选择：每列是普通列表，选中某项后展开它的 [FlPickerListLinkageItem.children]。
/// 常用于省/市/区这类层级数据。
class FlMultiListLinkagePicker<T> extends FlPickerStatefulWidget<List<int>> {
  const FlMultiListLinkagePicker({
    super.key,
    super.options,
    super.height = kPickerDefaultHeight,
    super.width = double.infinity,
    super.itemWidth,
    required this.items,
    this.value = const [],
    this.isScrollable = true,
    this.itemExtent,
    this.onChanged,
    this.onValueChanged,
  }) : super(wheelOptions: null);

  /// 要渲染的层级数据
  final List<FlPickerListLinkageItem<T>> items;

  /// 是否横向滚动：true 时每列宽度为 [itemWidth] 或默认宽度；false 时各列均分宽度
  final bool isScrollable;

  /// 列表项的固定高度；各项高度一致时设置可提升滚动性能，为 null 时按实际高度布局
  final double? itemExtent;

  /// 初始选中的下标路径
  final List<int> value;

  /// 选择下标变化回调
  final FlPickerPositionIndexChanged? onChanged;

  /// 选择内容变化回调
  final FlPickerPositionValueChanged<T>? onValueChanged;

  @override
  State<FlMultiListLinkagePicker<T>> createState() => _FlMultiListLinkagePickerState<T>();
}

class _FlMultiListLinkagePickerState<T> extends State<FlMultiListLinkagePicker<T>> {
  late List<FlPickerListLinkageItem<T>> items;

  late List<int?> position;

  @override
  void initState() {
    super.initState();
    items = widget.items;
    position = _initialPosition();
  }

  /// 末尾保留一个空位，表示下一级尚未选择，点击后继续展开
  List<int?> _initialPosition() => _clampPosition([for (final int index in widget.value) index, null]);

  /// 按当前数据校正下标，避免数据变化后出现越界位置
  List<int?> _clampPosition(List<int?> raw) {
    final List<int?> result = [];
    List<FlPickerListLinkageItem<T>> currentEntry = items;
    for (int index = 0; index < raw.length && currentEntry.isNotEmpty; index++) {
      final int? value = raw[index];
      if (value == null) {
        result.add(null);
        currentEntry = currentEntry.first.children;
        continue;
      }
      final int itemPosition = value < 0 ? 0 : (value >= currentEntry.length ? currentEntry.length - 1 : value);
      result.add(itemPosition);
      currentEntry = currentEntry[itemPosition].children;
    }
    return result;
  }

  @override
  void didUpdateWidget(covariant FlMultiListLinkagePicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    items = widget.items;
    if (!_equalsList(oldWidget.value, widget.value)) {
      position = _initialPosition();
    } else if (!identical(oldWidget.items, widget.items)) {
      position = _clampPosition(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget current = _FlPickerColumnLayout(
      columns: buildList,
      width: widget.width,
      height: widget.height,
      isScrollable: widget.isScrollable,
      itemWidth: widget.itemWidth,
    );
    return _buildPicker<List<int>>(options: widget.options, child: current, confirmTap: () => getPosition);
  }

  final _FlPickerPositionTracker tracker = _FlPickerPositionTracker();

  List<int> get getPosition {
    final List<int> list = [];
    for (final int? element in position) {
      if (element == null) break;
      list.add(element);
    }
    return list;
  }

  void onChanged() {
    final List<int> current = getPosition;
    if (!tracker.isChanged(current)) return;
    widget.onChanged?.call(current);
    if (widget.onValueChanged == null) return;
    final List<T> value = [];
    List<FlPickerListLinkageItem<T>> resultList = items;
    for (final int index in current) {
      if (index >= resultList.length) break;
      value.add(resultList[index].value);
      resultList = resultList[index].children;
    }
    widget.onValueChanged!(value);
  }

  List<Widget> get buildList {
    final List<Widget> list = [];
    List<FlPickerListLinkageItem<T>> currentEntry = items;
    for (int index = 0; index < position.length; index++) {
      if (currentEntry.isEmpty) break;
      final int raw = position[index] ?? 0;
      final int itemPosition = raw < 0 ? 0 : (raw >= currentEntry.length ? currentEntry.length - 1 : raw);
      list.add(scrollList(positionIndex: index, positionValue: position[index], list: currentEntry));
      currentEntry = currentEntry[itemPosition].children;
    }
    return list;
  }

  Widget scrollList({
    required List<FlPickerListLinkageItem<T>> list,
    required int positionIndex,
    required int? positionValue,
  }) => ListView.builder(
    itemCount: list.length,
    itemExtent: widget.itemExtent,
    itemBuilder: (_, int index) {
      final bool selected = positionValue == index;
      return GestureDetector(
        onTap: () {
          // 已经有明确选择时重复点击不应清空更深层级
          if (selected) return;
          position[positionIndex] = index;
          if (positionIndex < position.length - 1) {
            position.removeRange(positionIndex + 1, position.length);
          }
          position.add(null);
          if (mounted) setState(() {});
          onChanged();
        },
        child: list[index].child(selected),
      );
    },
  );
}
