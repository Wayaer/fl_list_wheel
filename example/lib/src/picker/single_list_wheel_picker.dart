import 'package:example/main.dart';
import 'package:example/src/picker/picker_page.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class SingleListWheelPickerPage extends StatelessWidget {
  const SingleListWheelPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('SingleListWheelPicker'),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          ElevatedText('show SingleListWheelPicker', onTap: pick),
          BackCard(buildSingleListWheelPicker())
        ]);
  }

  SingleListWheelPicker buildSingleListWheelPicker(
          {PickerOptions<int>? options}) =>
      SingleListWheelPicker(
          options: options,
          itemBuilder: (BuildContext context, int index) => Center(
              child: Text(numberList[index],
                  style: Theme.of(context).textTheme.bodyLarge)),
          itemCount: numberList.length);

  Future<void> pick() async {
    final int? index =
        await buildSingleListWheelPicker(options: BasePickerOptions()).show();
    if (index != null) debugPrint(numberList[index].toString());
  }
}
