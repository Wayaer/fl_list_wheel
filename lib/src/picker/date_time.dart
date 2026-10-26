part of 'picker.dart';

extension FlDateTimePickerExtension on FlDateTimePicker {
  /// 打开选择器弹窗并返回选中的时间，取消时返回 null
  Future<DateTime?> show({FlPickerPresenter? presenter}) =>
      FlListWheel.showPicker<DateTime>(this, presenter: presenter);
}

/// 日期时间变化回调
typedef FlDateTimePickerChanged = void Function(DateTime dateTime);

/// 自定义单位文字的渲染方式
typedef FlDateTimePickerUnitBuilder = Widget Function(String? unit);

/// 自定义选项文字的渲染方式
typedef FlDateTimePickerContentBuilder = Widget Function(String content);

/// 日期时间选择器：年/月/日/时/分/秒各列独立联动。
/// 适合跨度较大的日期，不会一次性构建区间内的所有日期。
class FlDateTimePicker extends FlPickerStatefulWidget<DateTime> {
  FlDateTimePicker({
    super.key,
    super.options,
    super.wheelOptions,
    super.height = kPickerDefaultHeight,
    super.width = double.infinity,
    super.itemWidth,
    this.unit = const FlDateTimePickerUnit.all(),
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
  final FlDateTimePickerUnit unit;

  /// 自定义选项文字的渲染方式
  final FlDateTimePickerContentBuilder? itemBuilder;

  /// 开始时间
  final DateTime startDate;

  /// 默认选中时间，超出区间时会自动收敛到边界
  final DateTime defaultDate;

  /// 结束时间
  final DateTime endDate;

  /// 选择时间变化回调
  final FlDateTimePickerChanged? onChanged;

  @override
  State<FlDateTimePicker> createState() => _FlDateTimePickerState();
}

/// 日期时间选择器中的一列滚轮，统一管理数据、选中下标与 controller
class _FlWheelColumn {
  _FlWheelColumn(this.data);

  /// 当前列的数据
  List<int> data;

  /// 当前选中的下标
  int index = 0;

  /// 滚动控制器；该列被隐藏时为 null
  FixedExtentScrollController? controller;

  /// 列可见且尚未创建 controller 时创建，初始位置为 [index]
  void ensureController(bool visible) {
    if (!visible || controller != null) return;
    controller = FixedExtentScrollController(initialItem: index);
  }

  /// 滚动到 [target]；controller 未附着或已经在该下标时忽略
  void jumpTo(int target) {
    final FixedExtentScrollController? current = controller;
    if (current == null || !current.hasClients) return;
    final int safeTarget = target < 0 ? 0 : target;
    if (safeTarget != current.selectedItem) current.jumpToItem(safeTarget);
  }

  /// 销毁 controller
  void dispose() => controller?.dispose();
}

class _FlDateTimePickerState extends State<FlDateTimePicker> {
  /// 数字滚轮的宽度；单位文字紧跟其右侧，整体居中
  static const double wheelWidth = 64;

  final _FlWheelColumn year = _FlWheelColumn(<int>[]);
  final _FlWheelColumn month = _FlWheelColumn(<int>[]);
  final _FlWheelColumn day = _FlWheelColumn(<int>[]);
  final _FlWheelColumn hour = _FlWheelColumn(<int>[]);
  final _FlWheelColumn minute = _FlWheelColumn(<int>[]);
  final _FlWheelColumn second = _FlWheelColumn(<int>[]);

  /// 时间
  late DateTime startDate, defaultDate, endDate;

  late FlDateTimePickerUnit unit;

  bool isScrolling = false;

  StateSetter? dayState;

  @override
  void initState() {
    super.initState();
    initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onChanged();
    });
  }

  void initialize() {
    unit = widget.unit;
    final range = _normalizeDateRange(
      startDate: widget.startDate,
      defaultDate: widget.defaultDate,
      endDate: widget.endDate,
    );
    startDate = range.start;
    defaultDate = range.defaultDate;
    endDate = range.end;
    year
      ..data = List.generate(endDate.year - startDate.year + 1, (int index) => startDate.year + index)
      ..index = defaultDate.year - startDate.year
      ..ensureController(unit.year != null);
    month
      ..data = addList(12)
      ..index = defaultDate.month - 1
      ..ensureController(unit.month != null);
    day
      ..data = calculateDayNumber(isFirst: true)
      ..index = defaultDate.day - 1
      ..ensureController(unit.day != null);
    hour
      ..data = addList(24)
      ..index = defaultDate.hour
      ..ensureController(unit.hour != null);
    minute
      ..data = addList(60)
      ..index = defaultDate.minute
      ..ensureController(unit.minute != null);
    second
      ..data = addList(60)
      ..index = defaultDate.second
      ..ensureController(unit.second != null);
  }

  @override
  void didUpdateWidget(covariant FlDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool changed =
        oldWidget.unit != widget.unit ||
        oldWidget.dual != widget.dual ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.defaultDate != widget.defaultDate ||
        oldWidget.endDate != widget.endDate;
    if (!changed) return;
    initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      year.jumpTo(year.index);
      month.jumpTo(month.index);
      day.jumpTo(day.index);
      hour.jumpTo(hour.index);
      minute.jumpTo(minute.index);
      second.jumpTo(second.index);
      onChanged();
    });
  }

  int lastDateTime = 0;

  void onChanged() {
    final DateTime current = currentDateTime();
    final int microseconds = current.microsecondsSinceEpoch;
    if ((current.isAfter(startDate) || microseconds == startDate.microsecondsSinceEpoch) &&
        (current.isBefore(endDate) || microseconds == endDate.microsecondsSinceEpoch) &&
        microseconds != lastDateTime) {
      lastDateTime = microseconds;
      widget.onChanged?.call(current);
    }
  }

  /// wheel数组添加数据
  List<int> addList(int maxNumber) => List.generate(maxNumber, (int index) => index);

  /// 计算每月day的数量
  List<int> calculateDayNumber({bool isFirst = false}) {
    final int selectYearItem = isFirst ? (defaultDate.year - startDate.year) : year.index;
    final int selectMonthItem = isFirst ? defaultDate.month : month.index + 1;
    final int safeIndex = selectYearItem < 0
        ? 0
        : (selectYearItem >= year.data.length ? year.data.length - 1 : selectYearItem);
    final int selectedYear = year.data[safeIndex];
    // DateTime(year, month + 1, 0) 直接得到当月天数，不受夏令时影响
    return addList(DateTime(selectedYear, selectMonthItem + 1, 0).day);
  }

  /// 月份/年份变化后，把选中日修正到当月合法范围内
  void clampDayIndex() {
    if (day.data.isEmpty) {
      day.index = 0;
      return;
    }
    if (day.index < day.data.length) return;
    day.index = day.data.length - 1;
    day.jumpTo(day.index);
  }

  void refreshPosition() {
    if (isScrolling) return;
    isScrolling = true;
    final DateTime currentDate = currentDateTime();
    final int milliseconds = currentDate.millisecondsSinceEpoch;
    if (milliseconds < startDate.millisecondsSinceEpoch) {
      month.jumpTo(startDate.month - 1);
      day.jumpTo(startDate.day - 1);
      hour.jumpTo(startDate.hour);
      minute.jumpTo(startDate.minute);
      second.jumpTo(startDate.second);
    } else if (milliseconds > endDate.millisecondsSinceEpoch) {
      month.jumpTo(endDate.month - 1);
      day.jumpTo(endDate.day - 1);
      hour.jumpTo(endDate.hour);
      minute.jumpTo(endDate.minute);
      second.jumpTo(endDate.second);
    }
    isScrolling = false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rowChildren = [];
    if (unit.year != null) {
      rowChildren.add(
        wheelItem(
          year,
          unit: unit.year,
          flex: 3,
          onChanged: (int newIndex) {
            year.index = newIndex;
            if (month.index == 1) {
              day.data = calculateDayNumber();
              clampDayIndex();
              dayState?.call(() {});
            }
          },
        ),
      );
    }

    if (unit.month != null) {
      rowChildren.add(
        wheelItem(
          month,
          startZero: false,
          unit: unit.month,
          onChanged: (int newIndex) {
            month.index = newIndex;
            day.data = calculateDayNumber();
            clampDayIndex();
            dayState?.call(() {});
          },
        ),
      );
    }

    if (unit.day != null) {
      rowChildren.add(
        StatefulBuilder(
          builder: (_, StateSetter setState) {
            dayState = setState;
            return wheelItem(day, startZero: false, unit: unit.day, onChanged: (int newIndex) => day.index = newIndex);
          },
        ),
      );
    }

    if (unit.hour != null) {
      rowChildren.add(wheelItem(hour, unit: unit.hour, onChanged: (int newIndex) => hour.index = newIndex));
    }

    if (unit.minute != null) {
      rowChildren.add(wheelItem(minute, unit: unit.minute, onChanged: (int newIndex) => minute.index = newIndex));
    }

    if (unit.second != null) {
      rowChildren.add(wheelItem(second, unit: unit.second, onChanged: (int newIndex) => second.index = newIndex));
    }
    final Widget dateTime = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: rowChildren),
    );
    return _buildPicker<DateTime>(options: widget.options, child: dateTime, confirmTap: clampedDateTime);
  }

  DateTime currentDateTime() => DateTime(
    unit.year == null ? defaultDate.year : year.data[year.index],
    unit.month == null ? defaultDate.month : (month.data[month.index] + 1),
    unit.day == null ? defaultDate.day : (day.index >= day.data.length ? day.data.last : day.data[day.index] + 1),
    unit.hour == null ? defaultDate.hour : hour.data[hour.index],
    unit.minute == null ? defaultDate.minute : minute.data[minute.index],
    unit.second == null ? defaultDate.second : second.data[second.index],
    defaultDate.millisecond,
    defaultDate.microsecond,
  );

  /// 确认时把结果收敛到 [startDate, endDate]；
  /// 隐藏年份/月份列时选中的年份或月份仍取自默认值，可能出现越界，这里统一兜底
  DateTime clampedDateTime() {
    final DateTime current = currentDateTime();
    if (current.isBefore(startDate)) return startDate;
    if (current.isAfter(endDate)) return endDate;
    return current;
  }

  Widget wheelItem(
    _FlWheelColumn column, {
    String? unit,
    bool startZero = true,
    int flex = 2,
    ValueChanged<int>? onChanged,
  }) {
    final Widget wheel = buildListWheel(
      column: column,
      startZero: startZero,
      onChanged: (index) {
        onChanged?.call(index);
        refreshPosition();
      },
    );
    // 数字与单位作为紧凑整体居中，避免各列均分宽度后单位被推到两端
    final Widget current = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SizedBox(width: wheelWidth, child: wheel),
        ),
        if (unit != null && unit.isNotEmpty) ...[const SizedBox(width: 4), buildUnit(unit)],
      ],
    );
    return widget.itemWidth == null
        ? Flexible(
            flex: flex,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: current),
          )
        : SizedBox(
            width: widget.itemWidth,
            child: Center(child: current),
          );
  }

  Widget buildUnit(String? unit) =>
      widget.unit.builder?.call(unit) ??
      Center(widthFactor: 1, child: Text(unit!, style: Theme.of(context).textTheme.bodyLarge));

  Widget itemBuilder(int value) {
    final String content = widget.dual ? value.toString().padLeft(2, '0') : value.toString();
    return widget.itemBuilder?.call(content) ??
        Center(child: Text(content, style: Theme.of(context).textTheme.bodyLarge));
  }

  Widget buildListWheel({required _FlWheelColumn column, bool startZero = true, ValueChanged<int>? onChanged}) =>
      _FlPickerListWheel(
        controller: column.controller,
        itemCount: column.data.length,
        onChanged: (_) {},
        itemBuilder: (_, int index) => itemBuilder(startZero ? column.data[index] : column.data[index] + 1),
        onScrollEnd: (int index) {
          onChanged?.call(index);
          this.onChanged();
        },
        options: widget.wheelOptions,
      );

  @override
  void dispose() {
    year.dispose();
    month.dispose();
    day.dispose();
    hour.dispose();
    minute.dispose();
    second.dispose();
    super.dispose();
  }
}

/// 日期时间选择器显示哪些列及单位文字。
/// 字段为 null 时隐藏该列；为空字符串时显示该列但不显示单位文字。
class FlDateTimePickerUnit {
  /// 所有列都显示，但不显示单位文字
  const FlDateTimePickerUnit.none({
    this.builder,
    this.year = '',
    this.month = '',
    this.day = '',
    this.hour = '',
    this.minute = '',
    this.second = '',
  });

  /// 年、月、日、时、分、秒
  const FlDateTimePickerUnit.all({
    this.builder,
    this.year = 'Y',
    this.month = 'M',
    this.day = 'D',
    this.hour = 'H',
    this.minute = 'M',
    this.second = 'S',
  });

  /// 年、月、日、时、分
  const FlDateTimePickerUnit.ydm({
    this.builder,
    this.year = 'Y',
    this.month = 'M',
    this.day = 'D',
    this.hour = 'H',
    this.minute = 'M',
  }) : second = null;

  /// 年、月、日、时
  const FlDateTimePickerUnit.yh({this.builder, this.year = 'Y', this.month = 'M', this.day = 'D', this.hour = 'H'})
    : minute = null,
      second = null;

  /// 年、月、日
  const FlDateTimePickerUnit.yd({this.builder, this.year = 'Y', this.month = 'M', this.day = 'D'})
    : hour = null,
      minute = null,
      second = null;

  /// 年、月
  const FlDateTimePickerUnit.ym({this.builder, this.year = 'Y', this.month = 'M'})
    : day = null,
      hour = null,
      minute = null,
      second = null;

  /// 月、日
  const FlDateTimePickerUnit.md({this.builder, this.month = 'M', this.day = 'D'})
    : year = null,
      hour = null,
      minute = null,
      second = null;

  /// 月、日、时
  const FlDateTimePickerUnit.mh({this.builder, this.month = 'M', this.day = 'D', this.hour = 'H'})
    : year = null,
      minute = null,
      second = null;

  /// 月、日、时、分
  const FlDateTimePickerUnit.mm({this.builder, this.month = 'M', this.day = 'D', this.hour = 'H', this.minute = 'M'})
    : year = null,
      second = null;

  /// 月、日、时、分、秒
  const FlDateTimePickerUnit.mhs({
    this.builder,
    this.month = 'M',
    this.day = 'D',
    this.hour = 'H',
    this.minute = 'M',
    this.second = 'S',
  }) : year = null;

  /// 日、时、分、秒
  const FlDateTimePickerUnit.ds({this.builder, this.day = 'D', this.hour = 'H', this.minute = 'M', this.second = 'S'})
    : month = null,
      year = null;

  /// 日、时、分
  const FlDateTimePickerUnit.dm({this.builder, this.day = 'D', this.hour = 'H', this.minute = 'M'})
    : second = null,
      month = null,
      year = null;

  /// 日、时
  const FlDateTimePickerUnit.dh({this.builder, this.day = 'D', this.hour = 'H'})
    : minute = null,
      second = null,
      month = null,
      year = null;

  /// 时、分、秒
  const FlDateTimePickerUnit.hs({this.builder, this.hour = 'H', this.minute = 'M', this.second = 'S'})
    : year = null,
      month = null,
      day = null;

  /// 时、分
  const FlDateTimePickerUnit.hm({this.builder, this.hour = 'H', this.minute = 'M'})
    : second = null,
      year = null,
      month = null,
      day = null;

  /// 分、秒
  const FlDateTimePickerUnit.ms({this.builder, this.minute = 'M', this.second = 'S'})
    : hour = null,
      year = null,
      month = null,
      day = null;

  /// 年份列单位；null 表示隐藏年份列
  final String? year;

  /// 月份列单位；null 表示隐藏月份列
  final String? month;

  /// 日期列单位；null 表示隐藏日期列
  final String? day;

  /// 小时列单位；null 表示隐藏小时列
  final String? hour;

  /// 分钟列单位；null 表示隐藏分钟列
  final String? minute;

  /// 秒列单位；null 表示隐藏秒列
  final String? second;

  /// 自定义单位文字的渲染方式
  final FlDateTimePickerUnitBuilder? builder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlDateTimePickerUnit &&
          other.year == year &&
          other.month == month &&
          other.day == day &&
          other.hour == hour &&
          other.minute == minute &&
          other.second == second;

  @override
  int get hashCode => Object.hash(year, month, day, hour, minute, second);
}
