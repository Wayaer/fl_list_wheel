import 'package:example/main.dart';
import 'package:example/src/picker/area.dart';
import 'package:example/src/picker/picker_page.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class MultiListLinkagePickerPage extends StatefulWidget {
  const MultiListLinkagePickerPage({super.key});

  @override
  State<MultiListLinkagePickerPage> createState() =>
      _MultiListLinkagePickerState();
}

class _MultiListLinkagePickerState extends State<MultiListLinkagePickerPage> {
  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('MultiListLinkagePicker'),
        padding: const EdgeInsets.all(15),
        children: [
          ElevatedText('show MultiListLinkagePicker with area',
              onTap: () => pick(mapToLinkageItems(areaDataMap))),
          BackCard(buildMultiListLinkagePicker(mapToLinkageItems(areaDataMap))),
          const SizedBox(height: 20),
          ElevatedText('show MultiListLinkagePicker with custom',
              onTap: () => pick(mapToLinkageItems(mapABC))),
          BackCard(buildMultiListLinkagePicker(mapToLinkageItems(mapABC))),
        ]);
  }

  Future<void> pick(List<PickerListLinkageItem<String>> items) async {
    final List<int>? index =
        await buildMultiListLinkagePicker(items, options: BasePickerOptions())
            .show();
    List<PickerListLinkageItem> resultList = items;
    List<String> result = [];
    index?.map((item) {
      result.add(resultList[item].value);
      resultList = resultList[item].children;
    }).toList();
    if (result.isNotEmpty) debugPrint(result.toString());
  }

  MultiListLinkagePicker<String> buildMultiListLinkagePicker(
          List<PickerListLinkageItem<String>> items,
          {PickerOptions<List<int>>? options}) =>
      MultiListLinkagePicker<String>(
          options: options,
          height: 300,
          onChanged: (List<int> index) {
            debugPrint('MultiListLinkagePicker onChanged= $index');
          },
          onValueChanged: (List<String> list) {
            debugPrint('MultiListLinkagePicker onValueChanged= $list');
          },
          items: items);

  List<PickerListLinkageItem<String>> mapToLinkageItems(
      Map<String, dynamic> map) {
    List<PickerListLinkageItem<String>> buildEntry(Map<String, dynamic> map) =>
        map.entries.map((entry) {
          final value = entry.value;
          List<PickerListLinkageItem<String>> valueList = [];
          if (value is Map<String, dynamic>) {
            valueList = buildEntry(value);
          } else if (value is List) {
            valueList = value
                .map((item) => PickerListLinkageItem<String>(
                    value: item,
                    child: (selected) => buildChild(item, selected)))
                .toList();
          }
          return PickerListLinkageItem<String>(
              value: entry.key,
              child: (selected) => buildChild(entry.key, selected),
              children: valueList);
        }).toList();
    return buildEntry(map);
  }

  Widget buildChild(String value, bool selected) {
    final color = Theme.of(context).primaryColor;
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: selected ? color : null,
            border: Border(right: BorderSide(color: color))),
        child: Text(value,
            style: TextStyle(
                fontSize: 10, color: selected ? Colors.white : null)));
  }
}
