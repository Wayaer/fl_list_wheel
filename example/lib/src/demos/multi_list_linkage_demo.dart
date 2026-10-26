import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/data/linkage_data.dart';
import 'package:example/src/widgets/demo_widgets.dart';

class MultiListLinkageDemoPage extends StatefulWidget {
  const MultiListLinkageDemoPage({super.key});

  @override
  State<MultiListLinkageDemoPage> createState() => _MultiListLinkageDemoPageState();
}

class _MultiListLinkageDemoPageState extends State<MultiListLinkageDemoPage> {
  late final List<FlPickerListLinkageItem<String>> _items = buildListLinkageItems(deviceCatalog);

  List<int> _position = const [0, 0, 0];

  String get _label => resolveListLinkageValues(_items, _position).join(' / ');

  void _onChanged(List<int> index) => setState(() => _position = index);

  Future<void> _showPicker() async {
    final List<int>? result = await FlMultiListLinkagePicker<String>(
      items: _items,
      value: _position,
      height: 300,
      options: demoPickerOptions<List<int>>(context, title: 'Select product'),
      onChanged: _onChanged,
    ).show();
    if (!mounted) return;
    if (result != null) _onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Linked list',
      subtitle: '不使用滚轮的多列联动列表，适合在弹窗中快速点选。',
      children: [
        DemoSection(
          title: 'Preview',
          subtitle: _label,
          component: 'FlMultiListLinkagePicker',
          code: 'FlMultiListLinkagePicker<String>(items: items).show()',
          child: SizedBox(
            height: 300,
            child: FlMultiListLinkagePicker<String>(
              items: _items,
              value: _position,
              height: 300,
              onChanged: _onChanged,
            ),
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
