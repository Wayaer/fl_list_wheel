import 'package:example/main.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

class ListWheelPage extends StatefulWidget {
  const ListWheelPage({super.key});

  @override
  State<ListWheelPage> createState() => _ListWheelPageState();
}

class _ListWheelPageState extends State<ListWheelPage> {
  final numberList = ['一', '二', '三', '四', '五', '六', '七', '八', '十'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarText('ListWheel'),
      body: ListView(children: [
        const Partition('ListWheel.builder'),
        addBackboard(FlListWheel.builder(
            onSelectedItemChanged: (_) {
              debugPrint('ListWheel.builder : $_');
            },
            itemBuilder: (_, int index) => Text(numberList[index]),
            itemCount: numberList.length)),
        const Partition('ListWheel.count'),
        addBackboard(FlListWheel.count(
            options: const WheelOptions(),
            onSelectedItemChanged: (_) {
              debugPrint('ListWheel.count : $_');
            },
            children: numberList.map((item) => Text(item)).toList())),
        const Partition('ListWheelState.builder'),
        addBackboard(FlListWheelState(
            count: numberList.length,
            initialItem: 5,
            builder: (_) => FlListWheel.builder(
                controller: _,
                onSelectedItemChanged: (_) {
                  debugPrint('ListWheelState.builder : $_');
                },
                itemBuilder: (_, int index) => Text(numberList[index]),
                itemCount: numberList.length))),
        const Partition('ListWheelState.builder'),
        addBackboard(FlListWheelState(
            initialItem: 5,
            count: numberList.length,
            builder: (_) => FlListWheel.count(
                controller: _,
                options: const WheelOptions(),
                onSelectedItemChanged: (_) {
                  debugPrint('ListWheelState.builder : $_');
                },
                children: numberList.map((item) => Text(item)).toList()))),
      ]),
    );
  }

  Widget addBackboard(Widget child) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      height: 150,
      width: 230,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          boxShadow: getBoxShadow(), borderRadius: BorderRadius.circular(12)),
      child: child);

  List<BoxShadow> getBoxShadow(
          {int num = 1,
          Color color = Colors.black12,
          double? radius,
          BlurStyle blurStyle = BlurStyle.normal,
          double blurRadius = 0.05,
          double spreadRadius = 0.05,
          Offset? offset}) =>
      List.generate(
          num,
          (index) => BoxShadow(
              color: color,
              blurStyle: blurStyle,
              blurRadius: radius ?? blurRadius,
              spreadRadius: radius ?? spreadRadius,
              offset: offset ?? const Offset(0, 0)));
}

class Partition extends StatelessWidget {
  const Partition(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: Colors.grey.withOpacity(0.2),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}
