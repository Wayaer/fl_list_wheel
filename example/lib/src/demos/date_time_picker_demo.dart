import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

enum _DateTimeUnit { all, date, dayHour, hourMinute, minuteSecond }

class DateTimePickerDemoPage extends StatefulWidget {
  const DateTimePickerDemoPage({super.key});

  @override
  State<DateTimePickerDemoPage> createState() => _DateTimePickerDemoPageState();
}

class _DateTimePickerDemoPageState extends State<DateTimePickerDemoPage>
    with DemoWheelStyleState<DateTimePickerDemoPage> {
  late final DateTime _today = DateTime.now();

  final ValueNotifier<DateTime?> _value = ValueNotifier<DateTime?>(null);

  _DateTimeUnit _unit = _DateTimeUnit.all;

  DateTime get _start => _today.subtract(const Duration(days: 365));

  DateTime get _end => _today.add(const Duration(days: 365));

  FlDateTimePickerUnit get _dateTimeUnit => switch (_unit) {
    _DateTimeUnit.all => const FlDateTimePickerUnit.all(
      year: '年',
      month: '月',
      day: '日',
      hour: '时',
      minute: '分',
      second: '秒',
    ),
    _DateTimeUnit.date => const FlDateTimePickerUnit.yd(year: '年', month: '月', day: '日'),
    _DateTimeUnit.dayHour => const FlDateTimePickerUnit.dh(day: '日', hour: '时'),
    _DateTimeUnit.hourMinute => const FlDateTimePickerUnit.hm(hour: '时', minute: '分'),
    _DateTimeUnit.minuteSecond => const FlDateTimePickerUnit.ms(minute: '分', second: '秒'),
  };

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _showPicker() async {
    final DateTime? result = await FlDateTimePicker(
      height: 220,
      unit: _dateTimeUnit,
      wheelOptions: demoWheelOptions(demoStyle),
      options: demoPickerOptions<DateTime>(context, title: 'Select date & time'),
      startDate: _start,
      defaultDate: _value.value ?? _today,
      endDate: _end,
      onChanged: (DateTime value) => _value.value = value,
    ).show();
    if (!mounted) return;
    if (result != null) {
      _value.value = result;
      // 重建内联预览，使其同步到弹窗中选择的时间
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Date & time picker',
      subtitle: '可以自由组合年、月、日、时、分、秒滚轮，并自动按月份天数修正日期。',
      children: [
        DemoSection(
          title: 'Configuration',
          component: 'FlDateTimePickerUnit',
          code: 'FlDateTimePickerUnit.all()',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DemoChoices<_DateTimeUnit>(
                choices: const [
                  DemoChoice(_DateTimeUnit.all, 'All units'),
                  DemoChoice(_DateTimeUnit.date, 'Date only'),
                  DemoChoice(_DateTimeUnit.dayHour, 'Day · Hour'),
                  DemoChoice(_DateTimeUnit.hourMinute, 'Hour · Minute'),
                  DemoChoice(_DateTimeUnit.minuteSecond, 'Minute · Second'),
                ],
                selected: _unit,
                onChanged: (_DateTimeUnit value) => setState(() => _unit = value),
              ),
              const SizedBox(height: 10),
              DemoChoices<DemoWheelStyle>(
                choices: demoWheelStyleChoices,
                selected: demoStyle,
                onChanged: changeDemoStyle,
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Inline preview',
          subtitle: '日期滚轮会根据月份自动调整天数，切换到二月时不会出现越界下标。',
          component: 'FlDateTimePicker',
          code: 'FlDateTimePicker(unit: unit, options: options).show()',
          child: SizedBox(
            height: 220,
            child: FlDateTimePicker(
              height: 220,
              unit: _dateTimeUnit,
              startDate: _start,
              defaultDate: _value.value ?? _today,
              endDate: _end,
              wheelOptions: demoWheelOptions(demoStyle),
              onChanged: (DateTime value) => _value.value = value,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _showPicker,
            icon: const Icon(Icons.expand_more),
            label: const Text('Show as bottom sheet'),
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<DateTime?>(
          valueListenable: _value,
          builder: (_, DateTime? value, _) =>
              ResultPanel(entries: [ResultEntry('selected date time', value == null ? null : formatDateTime(value))]),
        ),
      ],
    );
  }
}
