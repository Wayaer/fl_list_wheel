import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/data/area.dart';
import 'package:example/src/data/linkage_data.dart';
import 'package:example/src/widgets/demo_widgets.dart';

class AreaDemoPage extends StatefulWidget {
  const AreaDemoPage({super.key});

  @override
  State<AreaDemoPage> createState() => _AreaDemoPageState();
}

class _AreaDemoPageState extends State<AreaDemoPage> with DemoWheelStyleState<AreaDemoPage> {
  late final List<FlPickerLinkageItem<String>> _items = buildWheelLinkageItems(areaDataMap, maxDepth: 3);

  List<int> _position = const [0, 0, 0];

  String get _label => resolveLinkageValues(_items, _position).join(' / ');

  void _onChanged(List<int> index) => setState(() => _position = index);

  Future<void> _showPicker() async {
    final List<int>? result = await FlMultiListWheelLinkagePicker<String>(
      items: _items,
      value: _position,
      height: 280,
      isScrollable: false,
      wheelOptions: demoWheelOptions(demoStyle),
      options: demoPickerOptions<List<int>>(context, title: 'Select area'),
      onChanged: _onChanged,
    ).show();
    if (!mounted) return;
    if (result != null) _onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Area picker',
      subtitle: '省 / 市 / 区三级联动，数据来自内置的行政区划 Map。',
      children: [
        DemoSection(
          title: 'Preview',
          subtitle: _label,
          component: 'FlMultiListWheelLinkagePicker',
          code: 'FlMultiListWheelLinkagePicker<String>(items: areaItems).show()',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DemoChoices<DemoWheelStyle>(
                choices: demoWheelStyleChoices,
                selected: demoStyle,
                onChanged: changeDemoStyle,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: FlMultiListWheelLinkagePicker<String>(
                  items: _items,
                  value: _position,
                  height: 280,
                  isScrollable: false,
                  wheelOptions: demoWheelOptions(demoStyle),
                  onChanged: _onChanged,
                ),
              ),
            ],
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
        ResultPanel(entries: [ResultEntry('selected area', _label)]),
      ],
    );
  }
}
