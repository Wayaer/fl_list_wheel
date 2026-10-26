part of 'picker.dart';

extension FlDatePickerExtension on FlDatePicker {
  /// 打开选择器弹窗并返回选中的日期，取消时返回 null
  Future<DateTime?> show({FlPickerPresenter? presenter}) =>
      FlListWheel.showPicker<DateTime>(this, presenter: presenter);
}

/// 自定义选项文字的渲染方式
typedef FlDatePickerContentBuilder = Widget Function(String content);

/// 日期选择器：按日期区间生成年/月/日联动滚轮。
/// 区间内的日期会一次性全部构建，跨度很大时建议改用 [FlDateTimePicker]。
class FlDatePicker extends FlPickerStatefulWidget<DateTime> {
  /// 区间跨度上限（天），超出会在 debug 模式下断言失败，避免全量构建拖慢页面
  static const int maxRangeDays = 366 * 200;
  FlDatePicker({
    super.key,
    super.options,
    super.wheelOptions,
    super.height = kPickerDefaultHeight,
    super.width = double.infinity,
    super.itemWidth,
    this.unit = const FlDatePickerUnit.yd(),
    this.dual = true,
    this.itemBuilder,
    this.onChanged,
    DateTime? startDate,
    DateTime? defaultDate,
    DateTime? endDate,
  }) : startDate = startDate ?? DateTime.now().subtract(const Duration(days: 1)),
       defaultDate = defaultDate ?? DateTime.now(),
       endDate = endDate ?? DateTime.now();

  /// 是否把数字补成两位，如 1 → 01
  final bool dual;

  /// 决定显示哪些列，以及每列的单位文字
  /// 字段为 null 时隐藏该列；为空字符串时显示列但不显示单位文字
  final FlDatePickerUnit unit;

  /// 自定义选项文字的渲染方式；变化时会重建已生成的选项
  final FlDatePickerContentBuilder? itemBuilder;

  /// 开始日期
  final DateTime startDate;

  /// 默认选中日期，超出区间时会自动收敛到边界
  final DateTime defaultDate;

  /// 结束日期
  final DateTime endDate;

  /// 选择日期变化回调
  final FlDateTimePickerChanged? onChanged;

  @override
  State<FlDatePicker> createState() => _FlDatePickerState();
}

class _FlDateValue {
  _FlDateValue(this.value, this.dateTime);

  final String value;
  final DateTime dateTime;
}

class _FlDatePickerState extends State<FlDatePicker> {
  /// 时间
  late DateTime startDate, defaultDate, endDate;

  late FlDatePickerUnit unit;
  late List<FlPickerLinkageItem<_FlDateValue>> items;

  /// 当前每列选中的下标
  List<int> position = [];

  late bool hasYear;
  late bool hasMonth;
  late bool hasDay;

  @override
  void initState() {
    super.initState();
    initialize();
    // 与 FlDateTimePicker 对齐：首帧结束后回播一次初始选中值
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final DateTime? datetime = indexToDatetime(position);
      if (datetime != null) widget.onChanged?.call(datetime);
    });
  }

  /// 根据单位和日期区间重建联动数据，并计算默认选中位置
  void initialize() {
    items = [];
    unit = widget.unit;
    final range = _normalizeDateRange(
      startDate: widget.startDate,
      defaultDate: widget.defaultDate,
      endDate: widget.endDate,
    );
    startDate = range.start;
    defaultDate = range.defaultDate;
    endDate = range.end;
    final List<DateTime> rangeDate = startDate.getDaysForRange(endDate);
    assert(
      rangeDate.length <= FlDatePicker.maxRangeDays,
      'FlDatePicker 区间跨度 ${rangeDate.length} 天超过上限 ${FlDatePicker.maxRangeDays} 天，'
      '区间内的日期会一次性全部构建，请缩小区间或改用 FlDateTimePicker。',
    );
    int yI = 0;
    int mI = 0;
    hasYear = unit.year != null;
    hasDay = unit.day != null;
    // 只有日期没有月份时无法按天分组，自动显示月份列，避免越界
    hasMonth = unit.month != null || hasDay;
    // 不显示年份时，同一月份只保留首次出现的一次，避免跨年出现多个“01月”
    final Set<int> shownMonths = {};
    bool skipMonth = false;

    for (int i = 0; i < rangeDate.length; i++) {
      final DateTime current = rangeDate[i];
      DateTime? previous;
      if (i > 0) previous = rangeDate[i - 1];
      if (hasYear) {
        if (previous != null && current.year == previous.year) {
          if (current.month == previous.month) {
            if (!hasDay) continue;
            addDay(current, items[yI].children[mI].children);
          } else {
            mI += 1;
            if (!hasMonth) continue;
            addMonth(current, items[yI].children);
          }
        } else {
          if (previous != null) {
            mI = 0;
            yI += 1;
          }
          final FlPickerLinkageItem<_FlDateValue> entry = buildEntry(
            current,
            current.year,
            unit.year,
            hasMonth ? buildEntry(current, current.month, unit.month) : null,
          );
          items.add(entry);
        }
      } else {
        if (previous != null && current.month == previous.month) {
          if (skipMonth || !hasDay) continue;
          addDay(current, items[mI].children);
        } else {
          if (!hasMonth) continue;
          // 重复出现的月份及其日期一起跳过，保证无年份时每个月份只出现一次
          if (!shownMonths.add(current.month)) {
            skipMonth = true;
            continue;
          }
          skipMonth = false;
          if (previous != null) mI += 1;
          addMonth(current, items);
        }
      }
    }
    position = defaultPosition;
  }

  /// 按年 → 月 → 日逐级查找默认选中项；某一级找不到时退回该级第一项
  List<int> get defaultPosition {
    final List<int> result = [];
    List<FlPickerLinkageItem<_FlDateValue>> current = items;
    if (hasYear && current.isNotEmpty) {
      final int index = indexOfItem(current, (item) => item.value.dateTime.year == defaultDate.year);
      result.add(index < 0 ? 0 : index);
      current = current[result.last].children;
    }
    if (hasMonth && current.isNotEmpty) {
      final int index = indexOfItem(current, (item) => item.value.dateTime.month == defaultDate.month);
      result.add(index < 0 ? 0 : index);
      current = current[result.last].children;
    }
    if (hasDay && current.isNotEmpty) {
      final int index = indexOfItem(current, (item) => item.value.dateTime.day == defaultDate.day);
      result.add(index < 0 ? 0 : index);
    }
    return result;
  }

  int indexOfItem(List<FlPickerLinkageItem<_FlDateValue>> list, bool Function(FlPickerLinkageItem<_FlDateValue>) test) {
    for (int i = 0; i < list.length; i++) {
      if (test(list[i])) return i;
    }
    return -1;
  }

  void addDay(DateTime current, List<FlPickerLinkageItem<_FlDateValue>> items) {
    items.add(buildEntry(current, current.day, unit.day));
  }

  void addMonth(DateTime current, List<FlPickerLinkageItem<_FlDateValue>> items) {
    items.add(
      buildEntry(current, current.month, unit.month, hasDay ? buildEntry(current, current.day, unit.day) : null),
    );
  }

  /// 构建一个选项；[secondary] 为下一级的初始子项
  FlPickerLinkageItem<_FlDateValue> buildEntry(
    DateTime dateTime,
    int value,
    String? unit, [
    FlPickerLinkageItem<_FlDateValue>? secondary,
  ]) {
    String text = widget.dual ? value.toString().padLeft(2, '0') : value.toString();
    Widget buildText() {
      text += unit ?? '';
      return widget.itemBuilder?.call(text) ?? Text(text);
    }

    return FlPickerLinkageItem<_FlDateValue>(
      value: _FlDateValue(text, dateTime),
      child: buildText(),
      children: [?secondary],
    );
  }

  @override
  void didUpdateWidget(covariant FlDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool changed =
        oldWidget.unit != widget.unit ||
        oldWidget.dual != widget.dual ||
        oldWidget.itemBuilder != widget.itemBuilder ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.defaultDate != widget.defaultDate ||
        oldWidget.endDate != widget.endDate;
    if (!changed) return;
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    final Widget wheels = FlMultiListWheelLinkagePicker<_FlDateValue>(
      items: items,
      value: position,
      wheelOptions: widget.wheelOptions,
      onChanged: (List<int> index) {
        position = index;
        if (widget.onChanged != null) {
          final DateTime? datetime = indexToDatetime(index);
          if (datetime != null) widget.onChanged!(datetime);
        }
      },
      width: widget.width,
      isScrollable: false,
      height: widget.height,
      itemWidth: widget.itemWidth,
    );
    return _buildPicker<DateTime>(
      options: widget.options,
      child: wheels,
      confirmTap: () => indexToDatetime(position) ?? defaultDate,
    );
  }

  /// 把每列下标转换为选中的日期，下标越界时自动收敛
  DateTime? indexToDatetime(List<int> index) {
    if (items.isEmpty) return null;
    FlPickerLinkageItem<_FlDateValue>? selected;
    List<FlPickerLinkageItem<_FlDateValue>> resultList = items;
    for (final int element in index) {
      if (resultList.isEmpty) break;
      final int i = element < 0 ? 0 : (element >= resultList.length ? resultList.length - 1 : element);
      selected = resultList[i];
      resultList = selected.children;
    }
    if (selected == null) return null;
    final DateTime dateTime = selected.value.dateTime;
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}

/// 日期选择器显示哪些列及单位文字。
/// 字段为 null 时隐藏该列；为空字符串时显示该列但不显示单位文字。
class FlDatePickerUnit {
  /// 年/月/日三列都显示，但不显示单位文字
  const FlDatePickerUnit.none() : year = '', month = '', day = '';

  /// 年 + 月 + 日
  const FlDatePickerUnit.yd({this.year = ' Y', this.month = ' M', this.day = ' D'});

  /// 年 + 月
  const FlDatePickerUnit.ym({this.year = ' Y', this.month = ' M'}) : day = null;

  /// 月 + 日（不显示年份；跨年区间中相同月份按首次出现去重，
  /// 确认时返回的日期年份取该月首次出现时的年份）
  const FlDatePickerUnit.md({this.month = ' M', this.day = ' D'}) : year = null;

  /// 年份列单位；null 表示隐藏年份列
  final String? year;

  /// 月份列单位；null 表示隐藏月份列
  final String? month;

  /// 日期列单位；null 表示隐藏日期列
  final String? day;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlDatePickerUnit && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}
