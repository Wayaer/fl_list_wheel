import 'package:example/main.dart';
import 'package:example/src/demos/area_demo.dart';
import 'package:example/src/demos/custom_picker_demo.dart';
import 'package:example/src/demos/date_picker_demo.dart';
import 'package:example/src/demos/date_time_picker_demo.dart';
import 'package:example/src/demos/multi_list_linkage_demo.dart';
import 'package:example/src/demos/multi_list_wheel_demo.dart';
import 'package:example/src/demos/multi_list_wheel_linkage_demo.dart';
import 'package:example/src/demos/presentation_demo.dart';
import 'package:example/src/demos/single_list_demo.dart';
import 'package:example/src/demos/single_list_wheel_demo.dart';
import 'package:example/src/demos/wheel_demo.dart';
import 'package:example/src/widgets/demo_widgets.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    FlListWheel.presenter = null;
  });

  testWidgets('home page renders', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FlListWheelExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('FlListWheel'), findsOneWidget);
    expect(find.text('List wheel'), findsOneWidget);
    expect(find.text('Pickers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  final Map<String, Widget> pages = {
    'wheel': const WheelDemoPage(),
    'date': const DatePickerDemoPage(),
    'dateTime': const DateTimePickerDemoPage(),
    'area': const AreaDemoPage(),
    'multiWheel': const MultiListWheelDemoPage(),
    'linkedWheel': const MultiListWheelLinkageDemoPage(),
    'linkedList': const MultiListLinkageDemoPage(),
    'singleList': const SingleListDemoPage(),
    'singleWheel': const SingleListWheelDemoPage(),
    'custom': const CustomPickerDemoPage(),
    'presentation': const PresentationDemoPage(),
  };

  for (final MapEntry<String, Widget> entry in pages.entries) {
    testWidgets('page ${entry.key} renders', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(theme: ThemeData(useMaterial3: true), home: entry.value));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  group('library behavior', () {
    testWidgets('FlListWheelState keeps its selection when the parent rebuilds', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final FixedExtentScrollController controller = FixedExtentScrollController();
      addTearDown(controller.dispose);

      Widget build() => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: FlListWheelState(
              controller: controller,
              count: 5,
              builder: (FixedExtentScrollController value) => FlListWheel.count(
                controller: value,
                onSelectedItemChanged: (_) {},
                children: const [Text('0'), Text('1'), Text('2'), Text('3'), Text('4')],
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(build());
      await tester.drag(find.byType(ListWheelScrollView), const Offset(0, -120));
      await tester.pumpAndSettle();

      final int selected = controller.selectedItem;
      expect(selected, greaterThan(0));

      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      expect(controller.selectedItem, selected);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FlDatePicker supports dual false and month-day units', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final Future<DateTime?> future = FlDatePicker(
        dual: false,
        unit: const FlDatePickerUnit.md(),
        options: FlPickerOptions<DateTime>(title: const Text('Date'), confirm: const Text('Done')),
        onChanged: (_) {},
      ).show();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(await future, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('show() requires a presenter', (WidgetTester tester) async {
      expect(
        () => FlDatePicker(options: FlPickerOptions<DateTime>(title: const Text('Date'))).show(),
        throwsA(isA<FlutterError>()),
      );
    });

    testWidgets('verifyConfirm false keeps the picker open', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final Future<int?> future = FlSingleListWheelPicker(
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) => Text('item $index'),
        options: FlPickerOptions<int>(
          cancel: const Text('Cancel'),
          confirm: const Text('Done'),
          verifyConfirm: (int? value) => false,
        ),
      ).show();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('inline picker does not close the surrounding page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlSingleListWheelPicker(
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) => Text('item $index'),
              options: FlPickerOptions<int>(confirm: const Text('Done')),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    test('FlWheelOptions.merge keeps the base style instead of switching it', () {
      const FlWheelOptions cupertino = FlWheelOptions.cupertino(itemExtent: 32);
      final FlWheelOptions mergedCupertino = cupertino.merge(const FlWheelOptions(itemExtent: 40));
      expect(mergedCupertino.isCupertino, isTrue);
      expect(mergedCupertino.itemExtent, 40);

      const FlWheelOptions material = FlWheelOptions(itemExtent: 32);
      final FlWheelOptions mergedMaterial = material.merge(const FlWheelOptions.cupertino(itemExtent: 40));
      expect(mergedMaterial.isCupertino, isFalse);
      expect(mergedMaterial.itemExtent, 40);
    });

    testWidgets('FlListWheel forwards the onNotification result', (WidgetTester tester) async {
      bool bubbled = false;
      int notified = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              bubbled = true;
              return false;
            },
            child: SizedBox(
              height: 200,
              child: FlListWheel.count(
                onNotification: (ScrollNotification notification) {
                  notified += 1;
                  return true;
                },
                onSelectedItemChanged: (_) {},
                children: const [Text('0'), Text('1'), Text('2'), Text('3'), Text('4')],
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(FlListWheel), const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(notified, greaterThan(0));
      // 内层返回 true 表示通知已处理，不再向上冒泡
      expect(bubbled, isFalse);
    });

    testWidgets('single wheel clamps an out-of-range initial index', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final Future<int?> future = FlSingleListWheelPicker(
        itemCount: 3,
        initialIndex: 10,
        itemBuilder: (BuildContext context, int index) => Text('item $index'),
        options: FlPickerOptions<int>(confirm: const Text('Done')),
      ).show();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(await future, 2);
    });

    testWidgets('single wheel with no items confirms as null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final Future<int?> future = FlSingleListWheelPicker(
        itemCount: 0,
        itemBuilder: (BuildContext context, int index) => Text('item $index'),
        options: FlPickerOptions<int>(confirm: const Text('Done')),
      ).show();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(await future, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('multi wheel with an empty column confirms as null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final Future<List<int>?> future = FlMultiListWheelPicker(
        items: [
          FlPickerItem(itemCount: 3, itemBuilder: (BuildContext context, int index) => Text('item $index')),
          FlPickerItem(itemCount: 0, itemBuilder: (BuildContext context, int index) => const SizedBox()),
        ],
        options: FlPickerOptions<List<int>>(confirm: const Text('Done')),
      ).show();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(await future, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('single choice list keeps at most one initial selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final Future<List<int>?> future = FlSingleListPicker(
        itemCount: 5,
        initialIndex: const [1, 3],
        singleListPickerOptions: const FlSingleListPickerOptions(allowedMultipleChoice: false),
        itemBuilder: (BuildContext context, int index, bool isSelect, FlSelectIndexedChangedFunction change) =>
            Text('item $index'),
        options: FlPickerOptions<List<int>>(confirm: const Text('Done')),
      ).show();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(await future, [1]);
    });

    testWidgets('single list drops out-of-range selections when itemCount shrinks', (WidgetTester tester) async {
      int itemCount = 5;
      List<int>? result;
      late StateSetter rebuild;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              rebuild = setState;
              return Scaffold(
                body: FlPickerSession<List<int>>(
                  close: (List<int>? value) => result = value,
                  child: FlSingleListPicker(
                    itemCount: itemCount,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                      bool isSelect,
                      FlSelectIndexedChangedFunction change,
                    ) => GestureDetector(onTap: () => change(index), child: Text('item $index')),
                    options: FlPickerOptions<List<int>>(confirm: const Text('Done')),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('item 4'));
      await tester.pump();
      rebuild(() => itemCount = 3);
      await tester.pump();
      await tester.tap(find.text('item 0'));
      await tester.pump();
      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(result, [0]);
    });

    testWidgets('FlDatePicker emits the initial value after the first frame', (WidgetTester tester) async {
      DateTime? changed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FlDatePicker(onChanged: (DateTime value) => changed = value)),
        ),
      );
      await tester.pumpAndSettle();
      expect(changed, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FlDatePicker asserts on an excessive date range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlDatePicker(startDate: DateTime(1900), endDate: DateTime(2600)),
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('FlDatePicker rebuilds labels when itemBuilder changes', (WidgetTester tester) async {
      Widget build(String prefix) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: FlDatePicker(
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 3),
              defaultDate: DateTime(2024, 1, 1),
              itemBuilder: (String content) => Text('$prefix$content'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(build('A'));
      await tester.pumpAndSettle();
      expect(find.textContaining('A2024'), findsWidgets);

      await tester.pumpWidget(build('B'));
      await tester.pumpAndSettle();
      expect(find.textContaining('A2024'), findsNothing);
      expect(find.textContaining('B2024'), findsWidgets);
    });

    testWidgets('FlDateTimePicker clamps the initial value into the range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final DateTime start = DateTime(2024, 6, 15, 10, 30);
      final Future<DateTime?> future = FlDateTimePicker(
        startDate: start,
        endDate: DateTime(2024, 6, 17, 12),
        defaultDate: DateTime(2024, 6, 10),
        options: FlPickerOptions<DateTime>(confirm: const Text('Done')),
      ).show();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(await future, start);
    });

    testWidgets('FlDateTimePicker confirm never leaves the range', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final DateTime start = DateTime(2024, 6, 15);
      final DateTime end = DateTime(2025, 3, 10);
      final Future<DateTime?> future = FlDateTimePicker(
        // 隐藏月份列：选中年份后月份仍取自 defaultDate，可能落到区间之外
        unit: const FlDateTimePickerUnit.all(month: null),
        startDate: start,
        endDate: end,
        defaultDate: start,
        options: FlPickerOptions<DateTime>(confirm: const Text('Done')),
      ).show();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListWheelScrollView).first, const Offset(0, -90));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final DateTime? result = await future;
      expect(result, isNotNull);
      expect(result!.isBefore(start), isFalse);
      expect(result.isAfter(end), isFalse);
    });

    testWidgets('DateTimePicker clamps the day when the month changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              FlListWheel.presenter = FlBottomSheetPickerPresenter(context: () => context);
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final Future<DateTime?> future = FlDateTimePicker(
        unit: const FlDateTimePickerUnit.yd(),
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        defaultDate: DateTime(2024, 3, 31),
        options: FlPickerOptions<DateTime>(confirm: const Text('Done')),
      ).show();
      await tester.pumpAndSettle();

      // 月份列从 3 月滚到 2 月，31 日应自动收敛到 2 月 29 日
      await tester.drag(find.byType(ListWheelScrollView).at(1), const Offset(0, 45));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(await future, DateTime(2024, 2, 29));
    });

    testWidgets('FlDateTimePicker all columns fit a narrow screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      FlListWheel.wheelOptions = const FlWheelOptions();
      addTearDown(FlListWheel.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 260,
              child: FlDateTimePicker(
                unit: const FlDateTimePickerUnit.all(),
                startDate: DateTime(2024, 1, 1, 10, 30),
                endDate: DateTime(2024, 1, 1, 16, 50),
                defaultDate: DateTime(2024, 1, 1, 12, 40),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    test('demoWheelOptions does not change the global style', () {
      FlListWheel.wheelOptions = const FlWheelOptions.cupertino();
      addTearDown(FlListWheel.reset);

      demoWheelOptions(DemoWheelStyle.material);
      expect(FlListWheel.wheelOptions.isCupertino, isTrue);

      applyDemoWheelStyle(DemoWheelStyle.material);
      expect(FlListWheel.wheelOptions.isCupertino, isFalse);
    });
  });

  group('bottom sheets', () {
    Future<void> openPage(WidgetTester tester, Widget page) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(theme: ThemeData(useMaterial3: true), home: page));
      await tester.pumpAndSettle();
      FlListWheel.presenter = FlBottomSheetPickerPresenter(
        context: () => tester.element(find.byType(Scaffold).first),
        backgroundColor: Colors.transparent,
      );
    }

    testWidgets('date picker returns a date', (WidgetTester tester) async {
      await openPage(tester, const DatePickerDemoPage());
      await tester.tap(find.text('Show as bottom sheet'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('—'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('date time picker returns a date time', (WidgetTester tester) async {
      await openPage(tester, const DateTimePickerDemoPage());
      await tester.tap(find.text('Show as bottom sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('—'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('single list keeps the initial selection', (WidgetTester tester) async {
      await openPage(tester, const SingleListDemoPage());
      await tester.tap(find.text('Show as bottom sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Item 03 / Item 06'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('multi wheel returns all columns', (WidgetTester tester) async {
      await openPage(tester, const MultiListWheelDemoPage());
      await tester.tap(find.text('Show as bottom sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('C'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom picker returns the selected value', (WidgetTester tester) async {
      await openPage(tester, const CustomPickerDemoPage());
      await tester.tap(find.text('Open custom picker'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amber').last);
      await tester.pump();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Amber'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('area picker returns a position', (WidgetTester tester) async {
      await openPage(tester, const AreaDemoPage());
      await tester.tap(find.text('Show as bottom sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('selected area'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('presentation modes close through their own session', (WidgetTester tester) async {
      await openPage(tester, const PresentationDemoPage());

      await tester.tap(find.text('Global bottom sheet'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cupertino popup'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inline dialog + FlPickerSession'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Charlie'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
