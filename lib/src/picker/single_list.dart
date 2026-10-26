part of 'picker.dart';

extension FlSingleListPickerExtension on FlSingleListPicker {
  /// 打开选择器弹窗并返回选中的下标列表，取消时返回 null
  Future<List<int>?> show({FlPickerPresenter? presenter}) =>
      FlListWheel.showPicker<List<int>>(this, presenter: presenter);
}

/// 列表多选/单选选择器：基于普通 ListView，可通过 [FlSingleListPickerOptions] 控制选择方式。
class FlSingleListPicker extends StatefulWidget {
  const FlSingleListPicker({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialIndex = const [],
    this.height = kPickerDefaultHeight,
    this.width = double.infinity,
    this.options,
    this.singleListPickerOptions = const FlSingleListPickerOptions(),
    this.builder,
    this.onChanged,
  });

  /// 头部与背景配置；为 null 时不显示头部
  final FlPickerOptions<List<int>>? options;

  /// 初始选中的下标，越界或重复项会被忽略
  final List<int> initialIndex;

  /// 列表高度
  final double height;

  /// 列表宽度
  final double width;

  /// 子项数量
  final int itemCount;

  /// 按 index 渲染子项，并告知当前是否选中
  final FlSelectIndexedWidgetBuilder itemBuilder;

  /// 选择行为配置
  final FlSingleListPickerOptions singleListPickerOptions;

  /// 自定义列表容器，默认使用 ListView.builder
  final FlSelectScrollListBuilder? builder;

  /// 选中下标变化回调
  final FlPickerPositionIndexChanged? onChanged;

  @override
  State<FlSingleListPicker> createState() => _FlSingleListPickerState();
}

class _FlSingleListPickerState extends State<FlSingleListPicker> {
  late List<int> position;

  /// 过滤掉越界或重复的初始下标，避免确认时返回非法值；
  /// 单选模式下最多保留第一个有效下标
  List<int> get safeInitialIndex {
    final Set<int> result = {};
    final bool singleChoice = !widget.singleListPickerOptions.allowedMultipleChoice;
    for (final int index in widget.initialIndex) {
      if (index < 0 || index >= widget.itemCount || !result.add(index)) continue;
      if (singleChoice) break;
    }
    return result.toList();
  }

  @override
  void initState() {
    super.initState();
    _resetPosition();
  }

  void _resetPosition() {
    position = safeInitialIndex;
  }

  @override
  void didUpdateWidget(covariant FlSingleListPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_equalsList(oldWidget.initialIndex, widget.initialIndex) || oldWidget.itemCount != widget.itemCount) {
      _resetPosition();
    } else if (!widget.singleListPickerOptions.allowedMultipleChoice && position.length > 1) {
      // 从多选切到单选时只保留第一个选中项
      position = [position.first];
    }
  }

  /// 切换某一项的选中状态：多选时取反，单选时只保留这一项
  void _changeSelect([int? index]) {
    if (index == null) return;
    final List<int> previous = [...position];
    if (widget.singleListPickerOptions.allowedMultipleChoice) {
      if (position.contains(index)) {
        position.remove(index);
      } else {
        position.add(index);
      }
    } else {
      position = [index];
    }
    if (_equalsList(previous, position)) return;
    widget.onChanged?.call([...position]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Widget single = SizedBox(
      width: widget.width,
      height: widget.height,
      child: _FlSingleListPickerContent(
        selected: position,
        builder: widget.builder,
        singleListPickerOptions: widget.singleListPickerOptions,
        onChanged: _changeSelect,
        itemBuilder: widget.itemBuilder,
        itemCount: widget.itemCount,
      ),
    );
    return _buildPicker<List<int>>(options: widget.options, child: single, confirmTap: () => [...position]);
  }
}

/// 列表选择器的行为配置
class FlSingleListPickerOptions {
  const FlSingleListPickerOptions({
    this.isCustomGestureTap = false,
    this.allowedMultipleChoice = true,
    this.itemExtent,
  });

  /// 为 true 时由子项自行处理点击，组件不再包一层 GestureDetector
  final bool isCustomGestureTap;

  /// 是否允许同时选中多项；false 时每次只能选中一项
  final bool allowedMultipleChoice;

  /// 子项的固定高度；子项高度一致时设置可提升滚动性能，为 null 时按实际高度布局
  final double? itemExtent;
}

/// 构建列表子项：[isSelect] 表示是否选中，[changeFunc] 用于主动切换选中状态
typedef FlSelectIndexedWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  bool isSelect,
  FlSelectIndexedChangedFunction changeFunc,
);

/// 切换选中状态：[index] 为 null 时不改变选中项
typedef FlSelectIndexedChangedFunction = void Function([int? index]);

/// 自定义列表容器：[itemCount] 为子项数量，[itemBuilder] 用于逐项构建
typedef FlSelectScrollListBuilder = Widget Function(int itemCount, IndexedWidgetBuilder itemBuilder);

class _FlSingleListPickerContent extends StatelessWidget {
  const _FlSingleListPickerContent({
    required this.itemCount,
    required this.itemBuilder,
    required this.selected,
    required this.onChanged,
    required this.singleListPickerOptions,
    this.builder,
  });

  final int itemCount;
  final FlSelectIndexedWidgetBuilder itemBuilder;
  final List<int> selected;
  final FlSelectIndexedChangedFunction onChanged;
  final FlSelectScrollListBuilder? builder;
  final FlSingleListPickerOptions singleListPickerOptions;

  @override
  Widget build(BuildContext context) {
    Widget buildItem(BuildContext context, int index) {
      final Widget entry = itemBuilder(context, index, selected.contains(index), onChanged);
      if (singleListPickerOptions.isCustomGestureTap) return entry;
      return GestureDetector(onTap: () => onChanged(index), child: entry);
    }

    return builder?.call(itemCount, buildItem) ??
        ListView.builder(itemExtent: singleListPickerOptions.itemExtent, itemBuilder: buildItem, itemCount: itemCount);
  }
}
