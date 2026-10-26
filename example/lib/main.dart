import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:example/src/list_wheel_page.dart';
import 'package:example/src/picker/area_picker.dart';
import 'package:example/src/picker/date_picker.dart';
import 'package:example/src/picker/date_time_picker.dart';
import 'package:example/src/picker/multi_list_linkage_picker.dart';
import 'package:example/src/picker/multi_list_wheel_linkage_picker.dart';
import 'package:example/src/picker/multi_list_wheel_picker.dart';
import 'package:example/src/picker/single_list_picker.dart';
import 'package:example/src/picker/single_list_wheel_picker.dart';
import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DevicePreview(
      enabled: kIsWeb,
      defaultDevice: Devices.ios.iPhone13Mini,
      builder: (context) => MaterialApp(
          locale: DevicePreview.locale(context),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          builder: (BuildContext context, Widget? child) {
            return DevicePreview.appBuilder(context, child);
          },
          home: Scaffold(
              appBar: AppBar(title: const Text('FlScrollView')),
              body: const HomePage()))));
}

const List<Color> colorList = <Color>[
  ...Colors.accents,
  ...Colors.primaries,
];

class AppBarText extends AppBar {
  AppBarText(String text, {super.key})
      : super(
            elevation: 0,
            title: Text(text,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true);
}

class ElevatedText extends StatelessWidget {
  const ElevatedText(this.text, {this.onTap, super.key});

  final VoidCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    final current = ElevatedButton(onPressed: onTap, child: Text(text));
    if (defaultTargetPlatform == TargetPlatform.android &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      return current;
    }
    return Padding(padding: const EdgeInsets.all(10), child: current);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    FlListWheel.push = (Widget picker) {
      return showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
          builder: (_) => picker);
    };
    FlListWheel.pop = (dynamic value) {
      return Navigator.of(context).pop(value);
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          ElevatedText('FlListWheel', onTap: () {
            push(const ListWheelPage());
          }),
          ElevatedText('DatePicker', onTap: () {
            push(DatePickerPage());
          }),
          ElevatedText('DateTimePicker', onTap: () {
            push(DateTimePickerPage());
          }),
          ElevatedText('AreaPicker', onTap: () {
            push(const AreaPickerPage());
          }),
          ElevatedText('MultiListLinkagePicker', onTap: () {
            push(const MultiListLinkagePickerPage());
          }),
          ElevatedText('MultiListWheelPicker', onTap: () {
            push(const MultiListWheelPickerPage());
          }),
          ElevatedText('MultiListWheelLinkagePicker', onTap: () {
            push(const MultiListWheelLinkagePickerPage());
          }),
          ElevatedText('SingleListPicker', onTap: () {
            push(const SingleListPickerPage());
          }),
          ElevatedText('SingleListWheelPicker', onTap: () {
            push(const SingleListWheelPickerPage());
          }),
          ElevatedText('show CustomPicker', onTap: customPicker),
        ]);
  }

  Future<void> customPicker() async {
    Widget picker = CustomPicker<String>(
        options: PickerOptions<String>(
            decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            verifyConfirm: (String? value) {
              debugPrint('verifyConfirm $value');
              return true;
            },
            verifyCancel: (String? value) {
              debugPrint('verifyCancel $value');
              return true;
            },
            title: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('Title'))),
        content: Container(
            height: 300,
            alignment: Alignment.center,
            color: Colors.blue.withValues(alpha: 0.2),
            child: const Text('showCustomPicker',
                style: TextStyle(color: Colors.black))),
        confirmTap: () {
          return 'Confirm';
        },
        cancelTap: () {
          return 'Cancel';
        });
    final String? data = await showModalBottomSheet<String?>(
        context: context, builder: (_) => picker);
    debugPrint(data);
  }

  void push(Widget widget) {
    showCupertinoModalPopup(context: context, builder: (_) => widget);
  }
}

class ExtendedScaffold extends StatelessWidget {
  const ExtendedScaffold(
      {super.key, this.appBar, this.children = const [], this.padding});

  final AppBar? appBar;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget current = ListView(children: children);
    if (padding != null) {
      current = Padding(padding: padding!, child: current);
    }

    return Scaffold(appBar: appBar, body: current);
  }
}
