# fl_list_wheel

## Run [Web example](https://wayaer.github.io/fl_list_wheel/example/app/web/index.html#/)

### All the components

```dart

final picker = [

  /// FlListWheel
  FlListWheel.builder(),

  /// FlListWheel
  FlListWheel.count(),

  /// FlListWheelState
  FlListWheelState.builder(),

  /// FlListWheelState
  FlListWheelState.count(),

  /// date picker
  DatePicker(),

  /// date time picker
  DateTimePicker(),

  /// Multiple list combination
  MultiListLinkagePicker(),

  /// Multiple list wheel combination
  MultiListWheelLinkagePicker(),

  /// Single list
  SingleListPicker(),

  /// Single list wheel 
  SingleListWheelPicker(),
];

```

## If you use the show method, you must initialize the following two methods

## 如果使用show方法必须初始化以下两个方法

```dart
  @override
void initState() {
  super.initState();
  FlListWheel.push = (Widget picker) {
    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
        builder: (_) => picker);
  };
  FlListWheel.pop = (dynamic value) {
    return Navigator.of(context).pop(value);
  };
}
```

### `FlListWheel` and `FlListWheelState`

`FlListWheelState` can manage `FixedExtentScrollController` init and dispose
`FlListWheelState` 可以自己管理 `FixedExtentScrollController` init 和 dispose

```dart
Widget build() {
  return ListView(children: [
    FlListWheel.builder(
        onSelectedItemChanged: (_) {
          debugPrint('ListWheel.builder : $_');
        },
        itemBuilder: (_, int index) => Text(numberList[index]),
        itemCount: numberList.length),

    FlListWheel.count(
        options: const WheelOptions(),
        onSelectedItemChanged: (_) {
          debugPrint('ListWheel.count : $_');
        },
        children: numberList.map((item) => Text(item)).toList()),

    FlListWheelState(
        count: numberList.length,
        initialItem: 5,
        builder: (_) =>
            FlListWheel.builder(
                controller: _,
                onSelectedItemChanged: (_) {
                  debugPrint('ListWheelState.builder : $_');
                },
                itemBuilder: (_, int index) => Text(numberList[index]),
                itemCount: numberList.length)),
    FlListWheelState(
        initialItem: 5,
        count: numberList.length,
        builder: (_) =>
            FlListWheel.count(
                controller: _,
                options: const WheelOptions(),
                onSelectedItemChanged: (_) {
                  debugPrint('ListWheelState.builder : $_');
                },
                children: numberList.map((item) => Text(item)).toList()))
  ]);
}

```

### DatePicker

```dart
void func() {
  DatePicker().show();
}

Widget build() {
  return DatePicker(
      height: 200,
      startDate: defaultDate.subtract(const Duration(days: 365)),
      endDate: defaultDate.add(const Duration(days: 365)),
      defaultDate: defaultDate,
      options: options,
      onChanged: (DateTime dateTime) {
        debugPrint(dateTime.toString());
      },
      itemBuilder: (String text) =>
          Text(text, style: const TextStyle(fontSize: 16)),
      unit: const DatePickerUnit.yd(year: '年', day: '日', month: '月'));
}
```

### DateTimePicker

```dart
void func() {
  DateTimePicker().show();
}

Widget build() {
  return DateTimePicker(
      options: BasePickerOptions<DateTime>().merge(PickerOptions<DateTime>(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          verifyConfirm: (DateTime? dateTime) {
            debugPrint(dateTime?.toString() ?? 'verifyConfirm');
            return true;
          },
          verifyCancel: (DateTime? dateTime) {
            debugPrint(dateTime?.toString() ?? 'verifyCancel');
            return true;
          })),
      startDate: defaultDate.subtract(const Duration(days: 365)),
      defaultDate: defaultDate,
      endDate: defaultDate.add(const Duration(days: 365)),
      onChanged: (DateTime dateTime) {
        debugPrint(dateTime.toString());
      },
      height: 200,
      unit: const DateTimePickerUnit.yd(year: '年', month: '', day: ''));
}
```

### AreaPicker

```dart
void func() {
  Future<void> pick() async {
    final items = mapToLinkageItems(areaDataMap);
    final position = await MultiListWheelLinkagePicker<String>(
        wheelOptions: const WheelOptions.cupertino(),
        height: 200,
        onChanged: (List<int> index) {
          debugPrint('AreaPicker onChanged= $index');
        },
        onValueChanged: (List<String> list) {
          debugPrint('AreaPicker onValueChanged= $list');
        },
        items: mapToLinkageItems(areaDataMap),
        isScrollable: false)
        .show();
    if (position == null) return;
    List<String> value = [];
    List<PickerLinkageItem> resultList = items;
    position.map((index) {
      if (index < resultList.length) {
        value.add(resultList[index].value);
        resultList = resultList[index].children;
      }
    }).toList();
    debugPrint(value.toString());
  }
}

Widget build() {
  return MultiListWheelLinkagePicker<String>(
      options: options,
      wheelOptions: const WheelOptions.cupertino(),
      height: 200,
      onChanged: (List<int> index) {
        debugPrint('AreaPicker onChanged= $index');
      },
      onValueChanged: (List<String> list) {
        debugPrint('AreaPicker onValueChanged= $list');
      },
      items: mapToLinkageItems(areaDataMap),
      isScrollable: false);
}
```
