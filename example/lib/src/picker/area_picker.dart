import 'package:example/main.dart';
import 'package:example/src/picker/area.dart';
import 'package:example/src/picker/picker_page.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class AreaPickerPage extends StatelessWidget {
  const AreaPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('AreaPicker'),
        padding: const EdgeInsets.all(15),
        children: [
          ElevatedText('show AreaPicker', onTap: pick),
          BackCard(
              buildMultiListWheelLinkagePicker(mapToLinkageItems(areaDataMap))),
        ]);
  }

  MultiListWheelLinkagePicker buildMultiListWheelLinkagePicker(
    List<PickerLinkageItem<String>> items, {
    PickerOptions<List<int>>? options,
  }) =>
      MultiListWheelLinkagePicker<String>(
          options: options,
          wheelOptions: const WheelOptions.cupertino(),
          height: 200,
          onChanged: (List<int> index) {
            debugPrint('AreaPicker onChanged= $index');
          },
          onValueChanged: (List<String> list) {
            debugPrint('AreaPicker onValueChanged= $list');
          },
          items: items,
          isScrollable: false);

  Future<void> pick() async {
    final items = mapToLinkageItems(areaDataMap);
    final position = await buildMultiListWheelLinkagePicker(items,
            options: BasePickerOptions())
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

  List<PickerLinkageItem<String>> mapToLinkageItems(Map<String, dynamic> map) {
    List<PickerLinkageItem<String>> buildEntry(Map<String, dynamic> map) =>
        map.entries.map((entry) {
          final value = entry.value;
          List<PickerLinkageItem<String>> valueList = [];
          if (value is Map<String, dynamic>) {
            valueList = buildEntry(value);
          } else if (value is List) {
            valueList = value
                .map((item) => PickerLinkageItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 10))))
                .toList();
          }
          return PickerLinkageItem<String>(
              value: entry.key,
              child: Text(entry.key, style: const TextStyle(fontSize: 10)),
              children: valueList);
        }).toList();
    return buildEntry(map);
  }
}
