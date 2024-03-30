import 'package:example/main.dart';
import 'package:example/src/picker/picker_page.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class SingleListPickerPage extends StatelessWidget {
  const SingleListPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('SingleListPicker'),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          ElevatedText('show SingleListPicker', onTap: singleListPicker),
          ElevatedText('show SingleListPicker with screen',
              onTap: () => singleListPickerWithScreen(context)),
          ElevatedText('show SingleListPicker custom',
              onTap: customSingleListPicker),
          BackCard(Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleListPicker(
                height: 210,
                onChanged: (List<int> index) {
                  debugPrint(index.toString());
                },
                itemCount: numberList.length,
                builder: (int itemCount, IndexedWidgetBuilder itemBuilder) {
                  return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12),
                      itemBuilder: itemBuilder,
                      itemCount: itemCount);
                },
                itemBuilder: (context, index, isSelect, changedFun) {
                  return Container(
                      alignment: Alignment.center,
                      decoration: buildBoxDecoration(isSelect, context),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: buildText(index, isSelect, context));
                }),
          )),
        ]);
  }

  Future<void> customSingleListPicker() async {
    final list = List.generate(40, (index) => index.toString());
    final value = await SingleListPicker(
        itemCount: list.length,
        options: BasePickerOptions(),
        builder: (int itemCount, IndexedWidgetBuilder itemBuilder) {
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12),
              itemBuilder: itemBuilder,
              itemCount: itemCount);
        },
        itemBuilder: (context, index, isSelect, changedFun) {
          return Container(
              alignment: Alignment.center,
              decoration: buildBoxDecoration(isSelect, context),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: buildText(index, isSelect, context));
        }).show();
    debugPrint(value.toString());
  }

  Future<void> singleListPicker() async {
    final list = List.generate(40, (index) => index.toString());
    final value = await SingleListPicker(
        itemCount: list.length,
        options: BasePickerOptions(),
        singleListPickerOptions: const SingleListPickerOptions(
            isCustomGestureTap: true, allowedMultipleChoice: false),
        itemBuilder: (context, index, isSelect, changedFun) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText(index, isSelect, context),
                    Checkbox(
                        value: isSelect,
                        onChanged: (value) {
                          changedFun.call(index);
                        })
                  ]));
        }).show();
    debugPrint(value.toString());
  }

  Future<void> singleListPickerWithScreen(BuildContext context) async {
    final list = List.generate(40, (index) => index.toString());
    List<String> screen = [];
    final value = await SingleListPicker(
        itemCount: list.length,
        options: BasePickerOptions<List<int>>(),
        singleListPickerOptions: const SingleListPickerOptions(
            isCustomGestureTap: true, allowedMultipleChoice: false),
        itemBuilder: (context, index, isSelect, changedFun) {
          final entry = Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('第 $index 项'),
                    Checkbox(
                        value: isSelect,
                        onChanged: (value) {
                          changedFun(index);
                        })
                  ]));
          if (screen.isNotEmpty) {
            if (list[index] == screen.first) {
              return entry;
            }
            return const SizedBox();
          }
          return entry;
        }).show();
    debugPrint(value.toString());
  }

  BoxDecoration buildBoxDecoration(bool isSelect, BuildContext context) =>
      BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isSelect ? Theme.of(context).primaryColor : null);

  Widget buildText(int index, bool isSelect, BuildContext context) => Text(
        '第 $index 项',
        style: TextStyle(color: isSelect ? Colors.white : null),
      );
}
