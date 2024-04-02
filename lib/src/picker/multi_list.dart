part of 'picker.dart';

typedef PickerListLinkageItemBuilder = Widget Function(bool selected);

extension ExtensionMultiListLinkagePicker on MultiListLinkagePicker {
  Future<List<int>?> show() async {
    final result = await FlListWheel.pushFun.call(this);
    return result is List<int> ? result : null;
  }
}

class PickerListLinkageItem<T> {
  const PickerListLinkageItem(
      {required this.value, required this.child, this.children = const []});

  final PickerListLinkageItemBuilder child;

  final T value;

  final List<PickerListLinkageItem<T>> children;
}

/// 多列选择 联动
class MultiListLinkagePicker<T> extends PickerStatefulWidget<List<int>> {
  const MultiListLinkagePicker({
    super.key,
    super.options,
    super.height = kPickerDefaultHeight,
    super.width = double.infinity,
    super.itemWidth,
    required this.items,
    this.value = const [],
    this.isScrollable = true,
    this.onChanged,
    this.onValueChanged,
  }) : super(wheelOptions: null);

  /// 要渲染的数据
  final List<PickerListLinkageItem<T>> items;

  /// 是否可以横向滚动
  /// [isScrollable]==true 使用[SingleChildScrollView]创建
  /// [isScrollable]==false 使用[Row] 创建每个滚动，居中显示
  final bool isScrollable;

  /// 初始默认显示的位置
  final List<int> value;

  /// onChanged
  final PickerPositionIndexChanged? onChanged;

  /// onValueChanged
  final PickerPositionValueChanged<T>? onValueChanged;

  @override
  State<MultiListLinkagePicker<T>> createState() =>
      _MultiListLinkagePickerState<T>();
}

class _MultiListLinkagePickerState<T> extends State<MultiListLinkagePicker<T>> {
  List<PickerListLinkageItem<T>> items = [];
  List<int?> position = [null];
  int currentListLength = 0;

  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  @override
  void didUpdateWidget(covariant MultiListLinkagePicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    items = widget.items;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget current = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buildList.map((item) {
          Widget current = SizedBox(
              width: widget.isScrollable && widget.itemWidth == null
                  ? kPickerDefaultItemWidth
                  : widget.itemWidth,
              child: item);

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
            confirmTap: () => getPosition,
            child: current);
  }

  String lastPosition = '';

  List<int> get getPosition {
    List<int> list = [];
    for (var element in position) {
      if (element == null) continue;
      list.add(element);
    }
    return list;
  }

  void onChanged() {
    if (getPosition.toString() != lastPosition) {
      lastPosition = getPosition.toString();
      widget.onChanged?.call(getPosition);
      if (widget.onValueChanged != null) {
        List<T> value = [];
        List<PickerListLinkageItem> resultList = items;
        getPosition.map((index) {
          if (index < resultList.length) {
            value.add(resultList[index].value);
            resultList = resultList[index].children;
          }
        }).toList();
        widget.onValueChanged!(value);
      }
    }
  }

  List<Widget> get buildList {
    List<Widget> list = [];
    List<PickerListLinkageItem> currentEntry = items;
    List.generate(position.length, (index) {
      var itemPosition = position[index] ?? 0;
      if (currentEntry.isNotEmpty) {
        list.add(scrollList(
            positionIndex: index,
            positionValue: itemPosition,
            list: currentEntry));
        if (itemPosition < currentEntry.length) {
          currentEntry = currentEntry[itemPosition].children;
        } else {
          currentEntry = currentEntry.last.children;
        }
      }
    });
    return list;
  }

  Widget scrollList(
          {required List<PickerListLinkageItem> list,
          required int positionIndex,
          required int? positionValue}) =>
      ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, int index) {
            bool selected = position[positionIndex] == index;
            return GestureDetector(
                onTap: () {
                  if (selected) return;
                  position[positionIndex] = index;
                  if (positionIndex < position.length - 1) {
                    position.removeRange(positionIndex + 1, position.length);
                    position.add(null);
                  } else {
                    position.add(null);
                  }
                  if (mounted) setState(() {});
                  onChanged();
                },
                child: index > list.length
                    ? list.last.child(selected)
                    : list[index].child(selected));
          });
}
