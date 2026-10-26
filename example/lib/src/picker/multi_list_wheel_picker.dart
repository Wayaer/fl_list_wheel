import 'package:example/main.dart';
import 'package:example/src/picker/picker_page.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class MultiListWheelPickerPage extends StatelessWidget {
  const MultiListWheelPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('MultiListWheelPicker'),
        padding: const EdgeInsets.all(15),
        children: [
          ElevatedText('show MultiListWheelPicker', onTap: pick),
          const SizedBox(height: 20),
          BackCard(buildMultiListWheelPicker()),
        ]);
  }

  Future<void> pick() async {
    final List<int>? index = await buildMultiListWheelPicker(
            options: BasePickerOptions(), isScrollable: true)
        .show();
    if (index != null) {
      List<String> result = [];
      for (var element in index) {
        result.add(letterList[element]);
      }
      if (result.isNotEmpty) debugPrint(result.toString());
    }
  }

  MultiListWheelPicker buildMultiListWheelPicker(
          {PickerOptions<List<int>>? options, bool isScrollable = false}) =>
      MultiListWheelPicker(
          height: 200,
          options: options,
          wheelOptions: const WheelOptions.cupertino(),
          value: const [2, 3, 4, 6, 6],
          onChanged: (List<int> index) {
            debugPrint('MultiListWheelPicker onChanged= $index');
          },
          items: multiListWheelList);

  List<PickerItem> get multiListWheelList => List.generate(
      5,
      (_) => PickerItem(
          itemCount: letterList.length,
          itemBuilder: (_, int index) => Center(
              child: Text(letterList[index],
                  style: const TextStyle(fontSize: 16)))));
}
