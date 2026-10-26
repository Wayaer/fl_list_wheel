import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/data/linkage_data.dart';
import 'package:example/src/widgets/demo_widgets.dart';

class MultiListWheelLinkageDemoPage extends StatefulWidget {
  const MultiListWheelLinkageDemoPage({super.key});

  @override
  State<MultiListWheelLinkageDemoPage> createState() => _MultiListWheelLinkageDemoPageState();
}

class _MultiListWheelLinkageDemoPageState extends State<MultiListWheelLinkageDemoPage>
    with DemoWheelStyleState<MultiListWheelLinkageDemoPage> {
  late final List<FlPickerLinkageItem<String>> _items = buildWheelLinkageItems(deviceCatalog);

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
      options: demoPickerOptions<List<int>>(context, title: 'Select product'),
      onChanged: _onChanged,
    ).show();
    if (!mounted) return;
    if (result != null) _onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Linked wheel',
      subtitle: '多列滚轮联动：选择左侧列后，右侧列的数据会自动更新。',
      children: [
        DemoSection(
          title: 'Preview',
          subtitle: _label,
          component: 'FlMultiListWheelLinkagePicker',
          code: 'FlMultiListWheelLinkagePicker<String>(items: items).show()',
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
        ResultPanel(entries: [ResultEntry('selection', _label)]),
      ],
    );
  }
}
