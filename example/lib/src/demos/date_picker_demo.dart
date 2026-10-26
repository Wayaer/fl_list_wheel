import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

enum _DateUnit { ymd, ym, md }

class DatePickerDemoPage extends StatefulWidget {
  const DatePickerDemoPage({super.key});

  @override
  State<DatePickerDemoPage> createState() => _DatePickerDemoPageState();
}

class _DatePickerDemoPageState extends State<DatePickerDemoPage> with DemoWheelStyleState<DatePickerDemoPage> {
  late final DateTime _today = DateTime.now();

  final ValueNotifier<DateTime?> _value = ValueNotifier<DateTime?>(null);

  _DateUnit _unit = _DateUnit.ymd;

  DateTime get _start => DateTime(_today.year - 1, _today.month, _today.day);

  DateTime get _end => DateTime(_today.year + 1, _today.month, _today.day);

  FlDatePickerUnit get _datePickerUnit => switch (_unit) {
    _DateUnit.ymd => const FlDatePickerUnit.yd(year: '年', month: '月', day: '日'),
    _DateUnit.ym => const FlDatePickerUnit.ym(year: '年', month: '月'),
    _DateUnit.md => const FlDatePickerUnit.md(month: '月', day: '日'),
  };

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _showPicker() async {
    final DateTime? result = await FlDatePicker(
      height: 220,
      unit: _datePickerUnit,
      wheelOptions: demoWheelOptions(demoStyle),
      options: demoPickerOptions<DateTime>(context, title: 'Select a date'),
      startDate: _start,
      defaultDate: _value.value ?? _today,
      endDate: _end,
      onChanged: (DateTime value) => _value.value = value,
    ).show();
    if (!mounted) return;
    if (result != null) {
      _value.value = result;
      // 重建内联预览，使其同步到弹窗中选择的日期
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Date picker',
      subtitle: '按年月日联动滚轮，可只启用需要的单位；支持 show() 以底部弹窗方式打开。',
      children: [
        DemoSection(
          title: 'Configuration',
          component: 'FlDatePickerUnit',
          code: "FlDatePickerUnit.yd(year: ' Y', month: ' M', day: ' D')",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DemoChoices<_DateUnit>(
                choices: const [
                  DemoChoice(_DateUnit.ymd, 'Year · Month · Day'),
                  DemoChoice(_DateUnit.ym, 'Year · Month'),
                  DemoChoice(_DateUnit.md, 'Month · Day'),
                ],
                selected: _unit,
                onChanged: (_DateUnit value) => setState(() => _unit = value),
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
          subtitle: '未传 options 时不显示头部，通过 onChanged 实时回显。',
          component: 'FlDatePicker',
          code: 'FlDatePicker(unit: unit, options: options).show()',
          child: SizedBox(
            height: 220,
            child: FlDatePicker(
              height: 220,
              unit: _datePickerUnit,
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
              ResultPanel(entries: [ResultEntry('selected date', value == null ? null : formatDate(value))]),
        ),
      ],
    );
  }
}
