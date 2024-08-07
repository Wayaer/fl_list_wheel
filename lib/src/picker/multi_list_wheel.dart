part of 'picker.dart';

extension ExtensionMultiListWheelPicker on MultiListWheelPicker {
  Future<List<int>?> show() async {
    final result = await FlListWheel.pushFun.call(this);
    return result is List<int> ? result : null;
  }
}

class PickerItem {
  const PickerItem({required this.itemCount, required this.itemBuilder});

  /// 渲染子组件
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
}

/// 多列滚轮选择 不联动
class MultiListWheelPicker extends PickerStatelessWidget<List<int>> {
  const MultiListWheelPicker({
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

  /// 要渲染的数据
  final List<PickerItem> items;

  /// 初始默认显示的位置
  final List<int> value;

  /// 是否可以横向滚动
  /// [isScrollable]==true 使用[SingleChildScrollView]创建,[wheelOptions]中的[itemWidth]控制宽度，如果不设置则为[kPickerDefaultWidth]
  /// [isScrollable]==false 使用[Row] 创建每个滚动，居中显示
  final bool isScrollable;

  /// onIndexChanged
  final PickerPositionIndexChanged? onChanged;

  @override
  Widget build(BuildContext context) {
    List<int> position = [...value];
    String lastPosition = '';
    void onChanged() {
      if (position.length > items.length) {
        position.removeRange(items.length, position.length);
      }
      if (position.toString() != lastPosition) {
        lastPosition = position.toString();
        this.onChanged?.call(position);
      }
    }

    Widget current = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.asMap().entries.map((item) {
          if (items.length > position.length) position.add(0);
          final value = item.value;
          final location = item.key;
          FlListWheel buildWheel([FixedExtentScrollController? controller]) =>
              _PickerListWheel(
                  controller: controller,
                  options: wheelOptions,
                  itemBuilder: value.itemBuilder,
                  itemCount: value.itemCount,
                  onChanged: (int index) {
                    position[location] = index;
                  },
                  onScrollEnd: (_) => onChanged());

          Widget current = SizedBox(
              width: isScrollable && itemWidth == null
                  ? kPickerDefaultItemWidth
                  : itemWidth,
              child: this.value.isEmpty
                  ? buildWheel()
                  : FlListWheelState(
                      initialItem: position[item.key],
                      builder: buildWheel,
                      count: value.itemCount));
          return !isScrollable && itemWidth == null
              ? Expanded(child: current)
              : current;
        }).toList());
    if (isScrollable) {
      current = SingleChildScrollView(child: current);
    }
    current = SizedBox(width: width, height: height, child: current);
    return options == null
        ? current
        : PickerSubject<List<int>>(
            options: options!, child: current, confirmTap: () => position);
  }
}

class PickerLinkageItem<T> {
  const PickerLinkageItem(
      {required this.value, required this.child, this.children = const []});

  final Widget child;

  final T value;

  final List<PickerLinkageItem<T>> children;

  Map<String, dynamic> toMap() => {
        'child': child.runtimeType.toString(),
        'value': value.toString(),
        'children': children.map((item) => item.toMap()).toList(),
      };
}

extension ExtensionMultiListWheelLinkagePicker on MultiListWheelLinkagePicker {
  Future<List<int>?> show() async {
    final result = await FlListWheel.pushFun.call(this);
    return result is List<int> ? result : null;
  }
}

/// 多列滚轮选择 联动
class MultiListWheelLinkagePicker<T> extends PickerStatefulWidget<List<int>> {
  const MultiListWheelLinkagePicker({
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

  /// 要渲染的数据
  final List<PickerLinkageItem<T>> items;

  /// 是否可以横向滚动
  /// [isScrollable]==true 使用[SingleChildScrollView]创建,[wheelOptions]中的[itemWidth]控制宽度，如果不设置则为[kPickerDefaultWidth]
  /// [isScrollable]==false 使用[Row] 创建每个滚动，居中显示
  final bool isScrollable;

  /// 初始默认显示的位置
  final List<int> value;

  /// onChanged
  final PickerPositionIndexChanged? onChanged;

  /// onValueChanged
  final PickerPositionValueChanged<T>? onValueChanged;

  @override
  State<MultiListWheelLinkagePicker<T>> createState() =>
      _MultiListWheelLinkagePickerState<T>();
}

class _MultiListWheelLinkagePickerState<T>
    extends State<MultiListWheelLinkagePicker<T>> {
  List<PickerLinkageItem<T>> items = [];
  List<int> position = [];

  @override
  void initState() {
    super.initState();
    position = [...widget.value];
    items = [...widget.items];
  }

  int calculateDimension(List<PickerLinkageItem> list) {
    int highest = 0;
    if (list.isEmpty) return highest;
    for (var element in list) {
      int dimension = calculateDimension(element.children);
      if (dimension > highest) {
        highest = dimension;
      }
    }
    return highest + 1;
  }

  List<Widget> get buildWheels {
    final dimension = calculateDimension(items);
    List<Widget> list = [];
    List<PickerLinkageItem> itemsList = items;
    if (dimension > position.length) {
      List.generate((dimension - position.length), (index) => position.add(0));
    }
    for (int i = 0; i < position.length; i++) {
      int e = position[i];
      if (itemsList.isNotEmpty) {
        if (e >= itemsList.length) {
          e = itemsList.length - 1;
        }
        position[i] = e;
        list.add(listStateWheel(list: itemsList, location: i));
        itemsList = itemsList[e].children;
      } else {
        break;
      }
    }
    return list;
  }

  @override
  void didUpdateWidget(covariant MultiListWheelLinkagePicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    position = [...widget.value];
    items = [...widget.items];
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget current = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buildWheels.map((item) {
          Widget current = SizedBox(
              width: widget.isScrollable && widget.itemWidth == null
                  ? kPickerDefaultItemWidth
                  : widget.itemWidth,
              child: Align(alignment: Alignment.center, child: item));
          return !widget.isScrollable && widget.itemWidth == null
              ? Expanded(child: current)
              : current;
        }).toList());

    if (widget.isScrollable) {
      current = SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: current);
    }
    current =
        SizedBox(width: widget.width, height: widget.height, child: current);
    return widget.options == null
        ? current
        : PickerSubject<List<int>>(
            options: widget.options!,
            child: current,
            confirmTap: () => calculatePosition);
  }

  String lastPosition = '';

  List<int> get calculatePosition {
    final p = [...position];
    List<PickerLinkageItem> resultList = items;
    p.removeWhere((element) {
      if (resultList.isEmpty) {
        return true;
      } else {
        resultList = (element >= resultList.length
                ? resultList.last
                : resultList[element])
            .children;
        return false;
      }
    });
    return p;
  }

  void onChanged() {
    final p = calculatePosition;
    if (p.toString() != lastPosition) {
      lastPosition = p.toString();
      widget.onChanged?.call(p);
      if (widget.onValueChanged != null) {
        List<T> value = [];
        List<PickerLinkageItem> resultList = items;
        for (var index in p) {
          if (index < resultList.length) {
            value.add(resultList[index].value);
            resultList = resultList[index].children;
          }
        }
        widget.onValueChanged!(value);
      }
    }
  }

  Widget listStateWheel(
          {required List<PickerLinkageItem> list, required int location}) =>
      FlListWheelState(
          count: list.length,
          initialItem: position[location],
          builder: (controller) => _PickerListWheel(
              controller: controller,
              onChanged: (int index) {
                position[location] = index;
              },
              onScrollEnd: (int index) async {
                final builder =
                    list.length > index && list[index].children.isNotEmpty;
                if (location != position.length - 1 || builder) {
                  await Future.delayed(const Duration(milliseconds: 50));
                  if (mounted) setState(() {});
                }
                onChanged();
              },
              itemBuilder: (_, int index) => Center(
                  child: index > list.length
                      ? list.last.child
                      : list[index].child),
              itemCount: list.length,
              options: widget.wheelOptions));
}
