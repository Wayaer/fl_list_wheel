import 'package:example/main.dart';
import 'package:example/src/picker/area.dart';
import 'package:example/src/picker/picker_page.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class MultiListWheelLinkagePickerPage extends StatelessWidget {
  const MultiListWheelLinkagePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('MultiListWheelLinkagePicker'),
        padding: const EdgeInsets.all(15),
        children: [
          ElevatedText('show MultiListWheelLinkagePicker with area',
              onTap: () => pick(mapToLinkageItems(areaDataMap))),
          BackCard(buildMultiListWheelLinkagePicker(
              mapToLinkageItems(areaDataMap),
              isScrollable: true)),
          const SizedBox(height: 20),
          ElevatedText('show MultiListWheelLinkagePicker custom',
              onTap: () => pick(mapToLinkageItems(mapABC))),
          BackCard(buildMultiListWheelLinkagePicker(mapToLinkageItems(mapABC),
              isScrollable: true)),
        ]);
  }

  Future<void> pick(List<PickerLinkageItem<String>> items) async {
    final List<int>? index = await buildMultiListWheelLinkagePicker(items,
            options: BasePickerOptions(), isScrollable: false)
        .show();
    List<PickerLinkageItem> resultList = items;
    List<String> result = [];
    index?.map((item) {
      result.add(resultList[item].value);
      resultList = resultList[item].children;
    }).toList();
    if (result.isNotEmpty) debugPrint(result.toString());
  }

  MultiListWheelLinkagePicker<String> buildMultiListWheelLinkagePicker(
          List<PickerLinkageItem<String>> items,
          {PickerOptions<List<int>>? options,
          bool isScrollable = false}) =>
      MultiListWheelLinkagePicker<String>(
          height: 200,
          options: options,
          onChanged: (List<int> index) {
            debugPrint('MultiListWheelLinkagePicker onChanged= $index');
          },
          onValueChanged: (List<String> list) {
            debugPrint('MultiListWheelLinkagePicker onValueChanged= $list');
          },
          items: items,
          isScrollable: isScrollable);

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
                    child: Text(item,
                        maxLines: 1, style: const TextStyle(fontSize: 10))))
                .toList();
          }
          return PickerLinkageItem<String>(
              value: entry.key,
              child: Text(entry.key,
                  maxLines: 1, style: const TextStyle(fontSize: 10)),
              children: valueList);
        }).toList();
    return buildEntry(map);
  }
}
