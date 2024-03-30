import 'package:example/main.dart';
import 'package:example/src/picker/picker_page.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class DateTimePickerPage extends StatelessWidget {
  DateTimePickerPage({super.key});

  final DateTime defaultDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('DateTimePicker'),
        padding: const EdgeInsets.all(15),
        children: [
          ElevatedText('show DateTimePicker', onTap: pick),
          ElevatedText('show DateTimePicker with date',
              onTap: () => pick(const DateTimePickerUnit.yd())),
          BackCard(buildDateTimePicker(DateTimePickerUnit.all(
              builder: (value) => Text(
                    value ?? '',
                    style: const TextStyle(fontSize: 9),
                  )))),
          BackCard(buildDateTimePicker(
              const DateTimePickerUnit.yd(year: '年', month: '', day: ''))),
          BackCard(buildDateTimePicker(const DateTimePickerUnit.dh())),
        ]);
  }

  DateTimePicker buildDateTimePicker(DateTimePickerUnit unit,
          {PickerOptions<DateTime>? options}) =>
      DateTimePicker(
          options: options,
          startDate: defaultDate.subtract(const Duration(days: 365)),
          defaultDate: defaultDate,
          endDate: defaultDate.add(const Duration(days: 365)),
          onChanged: (DateTime dateTime) {
            debugPrint(dateTime.toString());
          },
          height: 200,
          unit: unit);

  Future<void> pick([DateTimePickerUnit? unit]) async {
    await buildDateTimePicker(unit ?? const DateTimePickerUnit.all(),
        options: BasePickerOptions<DateTime>().merge(PickerOptions<DateTime>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            verifyConfirm: (DateTime? dateTime) {
              debugPrint(dateTime?.toString() ?? 'verifyConfirm');
              return true;
            },
            verifyCancel: (DateTime? dateTime) {
              debugPrint(dateTime?.toString() ?? 'verifyCancel');
              return true;
            }))).show();
  }
}
