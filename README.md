# fl_list_wheel

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart)](https://dart.dev)
[![Pub](https://img.shields.io/badge/pub-1.0.0-0175C2)](https://pub.dev/packages/fl_list_wheel)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Extended `ListWheelScrollView` / `CupertinoPicker` with a unified option set, plus date, time, list and linkage
pickers.

- **Web demo:** https://wayaer.github.io/fl_list_wheel/example/app/web/index.html#/
- **Example source:** https://github.com/Wayaer/fl_list_wheel/tree/main/example
- **Pub package:** https://pub.dev/packages/fl_list_wheel

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Install](#install)
- [Quick start](#quick-start)
- [Global presenter and tests](#global-presenter-and-tests)
- [FlPickerOptions](#flpickeroptions)
- [FlWheelOptions](#flwheeloptions)
- [Wheels](#wheels)
- [FlDatePicker](#fldatepicker)
- [FlDateTimePicker](#fldatetimepicker)
- [FlMultiListWheelPicker](#flmultilistwheelpicker)
- [FlMultiListWheelLinkagePicker](#flmultilistwheellinkagepicker)
- [FlMultiListLinkagePicker](#flmultilistlinkagepicker)
- [FlSingleListPicker](#flsinglelistpicker)
- [FlSingleListWheelPicker](#flsinglelistwheelpicker)
- [FlCustomPicker](#flcustompicker)
- [Results and closing](#results-and-closing)
- [Layout constants](#layout-constants)
- [Web demo](#web-demo)
- [License](#license)

## Features

| Widget | Description |
| --- | --- |
| `FlListWheel` | `ListWheelScrollView` and `CupertinoPicker` behind one API |
| `FlListWheelState` | Creates / disposes a `FixedExtentScrollController`, keeps the selection on rebuild |
| `FlPickerPresenter` | Pluggable presentation: bottom sheet, Cupertino popup or a custom route |
| `FlPickerSession` | Lets inline pickers close a route you own and return a value |
| `FlDatePicker` | Year / month / day wheels, any unit combination |
| `FlDateTimePicker` | Year / month / day / hour / minute / second wheels |
| `FlMultiListWheelPicker` | Multiple independent wheel columns |
| `FlMultiListWheelLinkagePicker` | Multiple linked wheel columns (province → city → district) |
| `FlMultiListLinkagePicker` | Multiple linked non-wheel lists |
| `FlSingleListPicker` | List or grid selection, single or multiple choice |
| `FlSingleListWheelPicker` | Single wheel |
| `FlCustomPicker` | Header + confirm/cancel logic around any custom content |

All pickers share the same `FlPickerOptions` header and the same `show()` extension. Wheel-based pickers also share
the same `FlWheelOptions` styling.

## Requirements

- Flutter 3.47 or newer
- Dart 3.13 or newer

## Install

```yaml
dependencies:
  fl_list_wheel: ^1.0.0
```

## Quick start

`show()` needs a `FlPickerPresenter` to open and close the picker. Assign the global presenter once, for example when
your app starts:

```dart
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  FlListWheel.presenter = FlBottomSheetPickerPresenter(
    context: () => navigatorKey.currentContext!
  );

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      home: const HomePage()
    )
  );
}
```

Then open any picker from a page:

```dart
final DateTime? date = await FlDatePicker(
  options: FlPickerOptions<DateTime>(
    title: const Text('Select date'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  )
).show();
```

`show()` returns `null` when the user cancels.

## Global presenter and tests

`FlListWheel.presenter` is a single global object that opens the picker and installs a `FlPickerSession` so the
confirm/cancel buttons can close the correct route:

- Assign it once before calling `.show()`.
- Calling `.show()` without a presenter completes the returned `Future` with a `FlutterError` explaining the setup.
- The presenter is shared by the whole process. If your app uses several navigators, point `context` at the
  navigator you want, or implement your own `FlPickerPresenter`.
- Call `FlListWheel.reset()` to clear the presenter and restore the default wheel options, for example on sign-out.
- In widget tests, assign it in `setUp` and clear it in `tearDown`:

```dart
setUp(() {
  FlListWheel.presenter = FlBottomSheetPickerPresenter(
    context: () => navigatorKey.currentContext!
  );
});

tearDown(() {
  FlListWheel.presenter = null;
});
```

Custom presentation, for example a Cupertino modal popup:

```dart
class CupertinoSheetPresenter extends FlPickerPresenter {
  const CupertinoSheetPresenter({required this.context});

  final BuildContext Function() context;

  @override
  Future<T?> show<T>(Widget picker) => showCupertinoModalPopup<T>(
    context: context(),
    builder: (BuildContext routeContext) => FlPickerSession<T>(
      close: (T? value) => Navigator.of(routeContext).pop<T>(value),
      child: picker
    )
  );
}
```

### FlBottomSheetPickerPresenter options

| Field | Default | Description |
| --- | --- | --- |
| `context` | required | Returns the context used to find the navigator |
| `isScrollControlled` | `true` | Allow the sheet to be taller than half the screen |
| `useRootNavigator` | `false` | Open with the root navigator instead of the nearest one |
| `useSafeArea` | `false` | Avoid system intrusions |
| `backgroundColor` | `null` | Sheet background color |
| `barrierColor` | `null` | Barrier color |
| `shape` | `null` | Sheet shape, e.g. top rounded corners |

### Per-call presenter

The global presenter is only a default. Pass `presenter` to a single `show()` call to override it:

```dart
final DateTime? date = await FlDatePicker(
  options: FlPickerOptions<DateTime>(title: const Text('Select date'))
).show(
  presenter: FlBottomSheetPickerPresenter(
    context: () => context,
    useRootNavigator: true
  )
);
```

Use this for multiple navigators, a one-off transition, or a different presentation for a single screen. For a custom
picker widget that does not use one of the built-in extensions, call `FlListWheel.showPicker<T>(widget)` directly; it
uses the global presenter unless you pass `presenter`.

### Inline pickers and FlPickerSession

A picker rendered inline has no session, so its confirm/cancel buttons do not close anything. Wrap it in
`FlPickerSession` to connect those buttons to a route you control:

```dart
final int? result = await showDialog<int>(
  context: context,
  builder: (BuildContext dialogContext) => Dialog(
    child: FlPickerSession<int>(
      close: (int? value) => Navigator.of(dialogContext).pop(value),
      child: FlSingleListWheelPicker(
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) => Center(child: Text('Item $index')),
        options: FlPickerOptions<int>(
          title: const Text('Inline picker'),
          cancel: const Text('Cancel'),
          confirm: const Text('Done')
        )
      )
    )
  )
);
```

`FlPickerSession` is also the mechanism used internally by `FlBottomSheetPickerPresenter`. A custom presenter should
wrap the picker in `FlPickerSession` the same way so the header buttons can close its route.

## FlPickerOptions

`FlPickerOptions<T>` controls the header and the background shared by every picker:

| Field | Description |
| --- | --- |
| `top` | Content above the header, e.g. a drag handle |
| `cancel` | Left action; tapping it closes the sheet unless `verifyCancel` returns `false` |
| `title` | Center title |
| `confirm` | Right action; tapping it closes the sheet unless `verifyConfirm` returns `false` |
| `bottom` | Content below the header |
| `bottomNavigationBar` | Content below the picker body |
| `titlePadding` | Header padding, defaults to `EdgeInsets.all(10)` |
| `contentPadding` | Padding around the picker body |
| `backgroundColor` | Background color, ignored when `decoration` is set |
| `background` | Widget painted behind the picker body |
| `decoration` | Container decoration; wins over `backgroundColor` |
| `verifyConfirm` | `bool Function(T? value)`; return `false` to keep the sheet open |
| `verifyCancel` | Same as `verifyConfirm` for the cancel action |

If `options` is `null` the picker renders only its wheels and has no header. Confirm/cancel close the picker through
the `FlPickerSession` installed by the presenter; inline pickers have no session and never close the surrounding page.

Example with a full-width title and validation:

```dart
FlPickerOptions<int>(
  top: const SizedBox(height: 8),
  title: const Text('Pick a number'),
  cancel: const Text('Cancel'),
  confirm: const Text('Done'),
  titlePadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
  verifyConfirm: (int? value) => value != null
)
```

## FlWheelOptions

`FlWheelOptions` configures a wheel. Three constructors are available:

```dart
const FlWheelOptions();               // Material style, magnification 1.2
const FlWheelOptions.cupertino();     // iOS style with a selection overlay
const FlWheelOptions.custom(
  isCupertino: true,
  selectionOverlay: CupertinoPickerDefaultSelectionOverlay(),
  magnification: 1.1
);
```

Set a global default and override it per widget:

```dart
FlListWheel.wheelOptions = const FlWheelOptions.cupertino();

FlListWheel.builder(
  options: const FlWheelOptions(itemExtent: 36, magnification: 1.1),
  onSelectedItemChanged: (int index) => debugPrint('$index'),
  itemBuilder: (BuildContext context, int index) => Text(values[index]),
  itemCount: values.length
);
```

`options` / `wheelOptions` are merged into the global configuration: non-null fields override, `null` fields keep the
global value. The only exception is `isCupertino`, which always comes from the global configuration — a plain
`FlWheelOptions(...)` used to tweak a single wheel never switches the rendering style. Change the style globally via
`FlListWheel.wheelOptions` instead.

Important fields:

| Field | Applies to | Description |
| --- | --- | --- |
| `itemExtent` | both | Height of one item, default `30` |
| `diameterRatio` | both | Cylinder diameter / viewport height; larger is flatter |
| `squeeze` | both | Spacing between items; smaller means more spacing |
| `magnification` | both | Scale of the selected item when `useMagnifier` is true |
| `useMagnifier` | both | Enlarge the centered item |
| `offAxisFraction` | both | Horizontal offset of the selection |
| `physics` | Material / custom | Scroll physics; defaults to `FixedExtentScrollPhysics` so the wheel always snaps to whole items |
| `selectionOverlay` | Cupertino | Highlight behind the selected item |
| `backgroundColor` | Cupertino | Wheel background |
| `perspective` | Material / custom | 3D perspective strength |
| `overAndUnderCenterOpacity` | Material / custom | Opacity of off-center items |
| `renderChildrenOutsideViewport` | Material / custom | Paint items outside the viewport |
| `clipBehavior` | Material / custom | Clip mode |
| `scrollBehavior` / `restorationId` | Material / custom | Scroll configuration |

Material and custom wheels snap by default. To allow free scrolling, pass another physics:

```dart
const FlWheelOptions(physics: BouncingScrollPhysics())
```

## Wheels

### FlListWheel

```dart
FlListWheel.builder(
  onSelectedItemChanged: (int index) => debugPrint('builder $index'),
  itemBuilder: (BuildContext context, int index) => Text(values[index]),
  itemCount: values.length
);

FlListWheel.count(
  options: const FlWheelOptions(),
  onSelectedItemChanged: (int index) => debugPrint('count $index'),
  children: [for (final String value in values) Text(value)]
);

// Infinite looping:
FlListWheel.count(
  looping: true,
  onSelectedItemChanged: (int index) => debugPrint('looping $index'),
  children: [for (final String value in values) Text(value)]
);
```

Scroll callbacks (`onScrollStart`, `onScrollUpdate`, `onScrollEnd`) receive the current item index, even without a
controller. When `onNotification` is provided, the three convenience callbacks are skipped.

### FlListWheelState

`FlListWheelState` owns a `FixedExtentScrollController` when you do not provide one:

```dart
FlListWheelState(
  count: values.length,
  initialItem: 2,
  animateDuration: const Duration(milliseconds: 180),
  builder: (FixedExtentScrollController controller) => FlListWheel.builder(
    controller: controller,
    onSelectedItemChanged: (int index) => debugPrint('state $index'),
    itemBuilder: (BuildContext context, int index) => Text(values[index]),
    itemCount: values.length
  )
);
```

- `initialItem` is clamped to `0 .. count - 1`.
- If you pass your own `controller`, it stays yours and is never disposed by the widget.
- `onCreateController` exposes the controller created internally.
- `initialItem` changes are applied even before the controller is attached.

## FlDatePicker

```dart
final DateTime? date = await FlDatePicker(
  height: 200,
  unit: const FlDatePickerUnit.yd(year: ' Y', month: ' M', day: ' D'),
  startDate: DateTime.now().subtract(const Duration(days: 365)),
  defaultDate: DateTime.now(),
  endDate: DateTime.now().add(const Duration(days: 365)),
  options: FlPickerOptions<DateTime>(
    title: const Text('Select date'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  ),
  onChanged: (DateTime value) => debugPrint('$value')
).show();
```

Presets:

| Unit | Visible columns |
| --- | --- |
| `FlDatePickerUnit.yd()` | year, month, day |
| `FlDatePickerUnit.ym()` | year, month |
| `FlDatePickerUnit.md()` | month, day (no year) |
| `FlDatePickerUnit.none()` | year, month, day without unit text |

Set a field to `null` to hide its column, or to an empty string to show the column without a unit label.

Notes:

- The range is built day by day and is limited to `FlDatePicker.maxRangeDays` (200 years); wider ranges trigger an
  assertion in debug mode. Use `FlDateTimePicker` for very large ranges.
- Without a year column, each month is shown once (the first occurrence in the range).
- `defaultDate` is clamped to `[startDate, endDate]`.
- Changing `itemBuilder` rebuilds the generated options with the new labels.
- The confirmed value is normalized to the selected calendar day at midnight.
- `dual` pads single-digit values to two digits.

## FlDateTimePicker

```dart
final DateTime? dateTime = await FlDateTimePicker(
  height: 200,
  unit: const FlDateTimePickerUnit.ydm(
    year: 'Y',
    month: 'M',
    day: 'D',
    hour: 'H',
    minute: 'M'
  ),
  startDate: DateTime.now().subtract(const Duration(days: 30)),
  defaultDate: DateTime.now(),
  endDate: DateTime.now().add(const Duration(days: 30)),
  options: FlPickerOptions<DateTime>(title: const Text('Select date & time')),
  onChanged: (DateTime value) => debugPrint('$value')
).show();
```

Presets:

| Unit | Visible columns |
| --- | --- |
| `all()` | year, month, day, hour, minute, second |
| `none()` | all six columns, no unit text |
| `ydm()` | year, month, day, hour, minute |
| `yh()` | year, month, day, hour |
| `yd()` | year, month, day |
| `ym()` | year, month |
| `md()` | month, day |
| `mh()` | month, day, hour |
| `mm()` | month, day, hour, minute |
| `mhs()` | month, day, hour, minute, second |
| `ds()` | day, hour, minute, second |
| `dm()` | day, hour, minute |
| `dh()` | day, hour |
| `hs()` | hour, minute, second |
| `hm()` | hour, minute |
| `ms()` | minute, second |

Hidden columns keep the corresponding value from `defaultDate`. The day count is recomputed for the selected month and
the day index is clamped when you switch to a shorter month. The confirmed value is always clamped to
`[startDate, endDate]`.

## FlMultiListWheelPicker

Independent wheel columns, no linkage:

```dart
final List<int>? position = await FlMultiListWheelPicker(
  items: [
    FlPickerItem(
      itemCount: letters.length,
      itemBuilder: (BuildContext context, int index) => Center(child: Text(letters[index]))
    ),
    FlPickerItem(
      itemCount: numbers.length,
      itemBuilder: (BuildContext context, int index) => Center(child: Text(numbers[index]))
    )
  ],
  value: const [0, 0],
  isScrollable: false,
  height: 260,
  onChanged: (List<int> index) => debugPrint('$index'),
  options: FlPickerOptions<List<int>>(
    title: const Text('Select columns'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  )
).show();
```

- `value` is the initial index of each column and is clamped to the current data.
- The confirmed result is a `List<int>` with one index per column.
- If any column has `itemCount: 0`, confirming returns `null` because that column has no valid index.
- `isScrollable: true` wraps the columns in a horizontal `SingleChildScrollView`; each column uses `itemWidth` or
  `kPickerDefaultItemWidth`.
- `isScrollable: false` with no `itemWidth` makes the columns share the available width.

## FlMultiListWheelLinkagePicker

Wheel columns where each selection drives the next column:

```dart
final List<FlPickerLinkageItem<String>> items = [
  FlPickerLinkageItem<String>(
    value: 'Fujian',
    child: const Text('Fujian'),
    children: [
      FlPickerLinkageItem<String>(
        value: 'Fuzhou',
        child: const Text('Fuzhou'),
        children: [
          FlPickerLinkageItem<String>(value: 'Gulou', child: const Text('Gulou'))
        ]
      )
    ]
  )
];

final List<int>? position = await FlMultiListWheelLinkagePicker<String>(
  items: items,
  value: const [0, 0, 0],
  height: 280,
  isScrollable: false,
  onChanged: (List<int> index) => debugPrint('index $index'),
  onValueChanged: (List<String> value) => debugPrint('value $value'),
  options: FlPickerOptions<List<int>>(
    title: const Text('Select area'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  )
).show();
```

- The confirmed result is the index path (`List<int>`), not the values. Use `onValueChanged` if you need the values.
- Changing a column resets every deeper column to its first item.
- `onChanged` is called synchronously when a column stops scrolling, so a confirm tap right after scrolling reads the
  latest position.
- Limit the depth by only building `children` down to the levels you need.

## FlMultiListLinkagePicker

Linked columns built from ordinary lists instead of wheels:

```dart
final List<FlPickerListLinkageItem<String>> items = [
  FlPickerListLinkageItem<String>(
    value: 'Fujian',
    child: (bool selected) => ListTile(
      title: const Text('Fujian'),
      selected: selected
    ),
    children: [
      FlPickerListLinkageItem<String>(
        value: 'Fuzhou',
        child: (bool selected) => ListTile(
          title: const Text('Fuzhou'),
          selected: selected
        )
      )
    ]
  )
];

final List<int>? position = await FlMultiListLinkagePicker<String>(
  items: items,
  value: const [0, 0],
  height: 300,
  onChanged: (List<int> index) => debugPrint('$index'),
  options: FlPickerOptions<List<int>>(
    title: const Text('Select product'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  )
).show();
```

Each item builds its own appearance with `child(selected)`. Tapping an item selects it and opens the next level; the
confirmed result is the completed index path.

Set `itemExtent` when every row has the same height to let the lists lay out without measuring each child.

## FlSingleListPicker

List or grid selection, single or multiple choice:

```dart
final List<int>? selected = await FlSingleListPicker(
  itemCount: items.length,
  initialIndex: const [0, 2],
  singleListPickerOptions: const FlSingleListPickerOptions(
    allowedMultipleChoice: true,
    isCustomGestureTap: true
  ),
  options: FlPickerOptions<List<int>>(
    title: const Text('Select items'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  ),
  itemBuilder: (
    BuildContext context,
    int index,
    bool isSelect,
    FlSelectIndexedChangedFunction change
  ) => ListTile(
    title: Text(items[index]),
    selected: isSelect,
    onTap: () => change(index)
  )
).show();
```

- `allowedMultipleChoice` defaults to `true`; set it to `false` for single selection.
- `initialIndex` entries outside `0 .. itemCount - 1` are ignored; in single-choice mode only the first valid one
  is kept.
- `singleListPickerOptions.itemExtent` sets a fixed row height, which improves scrolling performance when every row
  has the same height.
- Set `isCustomGestureTap: true` when your item handles taps itself (as above); otherwise omit `onTap` and the picker
  wraps each item in a `GestureDetector`.
- Provide `builder` to replace the default `ListView.builder`, e.g. with a `GridView`.
- The confirmed result is the list of selected indices.

## FlSingleListWheelPicker

```dart
final int? index = await FlSingleListWheelPicker(
  initialIndex: 3,
  itemCount: months.length,
  height: 240,
  itemBuilder: (BuildContext context, int index) => Center(child: Text(months[index])),
  onChanged: (int index) => debugPrint('$index'),
  options: FlPickerOptions<int>(
    title: const Text('Select a month'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  )
).show();
```

- The confirmed result is the selected index.
- `onChanged` fires when scrolling ends.
- The picker owns the controller unless you pass `controller`; `initialIndex` changes are applied automatically.
- `initialIndex` is clamped to the current `itemCount`.

## FlCustomPicker

Header and confirm/cancel logic around any content:

```dart
final String? result = await FlCustomPicker<String>(
  options: FlPickerOptions<String>(
    title: const Text('Pick a color'),
    cancel: const Text('Cancel'),
    confirm: const Text('Done')
  ),
  content: StatefulBuilder(
    builder: (BuildContext context, StateSetter setSheetState) => Wrap(
      children: [
        for (final String color in colors)
          ChoiceChip(
            label: Text(color),
            selected: selectedColor == color,
            onSelected: (_) => setSheetState(() => selectedColor = color)
          )
      ]
    )
  ),
  confirmTap: () => selectedColor
).show();
```

`confirmTap` builds the confirmed value; `cancelTap` builds the cancel value (usually `null`). Both go through the
`verifyConfirm` / `verifyCancel` callbacks when provided.

## Results and closing

- `show()` returns the picker's value, or `null` when cancelled.
- `verifyConfirm(value)` and `verifyCancel(value)` return `false` to keep the sheet open.
- Closing is handled by `FlPickerSession`, which `FlBottomSheetPickerPresenter` installs around every picker.
  Custom presenters should do the same. Inline pickers have no session; wrap them in `FlPickerSession` if their confirm
  action should close a surrounding dialog.
- An `options` with `cancel` / `confirm` is required if you want the user to close the sheet.

## Layout constants

| Constant | Value | Description |
| --- | --- | --- |
| `kPickerDefaultHeight` | `180` | Default picker height |
| `kPickerDefaultItemWidth` | `90` | Column width used by horizontally scrollable pickers |

All pickers except `FlCustomPicker` accept `height` and `width`. Wheel pickers also accept `itemWidth` and
`wheelOptions`; `FlMultiListLinkagePicker` accepts `itemWidth` and `itemExtent`; `FlSingleListPicker` sets a fixed row
height with `FlSingleListPickerOptions.itemExtent`; `FlCustomPicker` only takes `options` and `content`.

## Web demo

A full web build of the example app is available at:

**https://wayaer.github.io/fl_list_wheel/example/app/web/index.html#/**

It covers every widget with inline previews, Material / Cupertino switching and bottom-sheet demos. Each example
section shows the component class name and a short usage snippet, so you can map the demo back to the API at a glance.
The `Presentation` page demonstrates the global presenter, a per-call Cupertino presenter and an inline
`FlPickerSession`. The source is in [`example/`](example).

## License

MIT
