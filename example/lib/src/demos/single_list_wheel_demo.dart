import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

class SingleListWheelDemoPage extends StatefulWidget {
  const SingleListWheelDemoPage({super.key});

  @override
  State<SingleListWheelDemoPage> createState() => _SingleListWheelDemoPageState();
}

class _SingleListWheelDemoPageState extends State<SingleListWheelDemoPage>
    with DemoWheelStyleState<SingleListWheelDemoPage> {
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late int _index = DateTime.now().month - 1;

  late final FixedExtentScrollController _controller = FixedExtentScrollController(initialItem: _index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(int index) => setState(() => _index = index);

  Future<void> _showPicker() async {
    final int? result = await FlSingleListWheelPicker(
      initialIndex: _index,
      itemCount: _months.length,
      height: 240,
      wheelOptions: demoWheelOptions(demoStyle),
      options: demoPickerOptions<int>(context, title: 'Select a month'),
      itemBuilder: (_, int index) => wheelText(_months[index]),
      onChanged: _onChanged,
    ).show();
    if (!mounted) return;
    if (result != null) {
      setState(() => _index = result);
      _controller.animateToItem(result, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Single wheel',
      subtitle: '单列滚轮，适合月份、数量、枚举等简单选择场景。',
      children: [
        DemoSection(
          title: 'Preview',
          subtitle: _months[_index],
          component: 'FlSingleListWheelPicker',
          code: 'FlSingleListWheelPicker(itemCount: 12, itemBuilder: ...).show()',
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
                height: 240,
                child: FlSingleListWheelPicker(
                  controller: _controller,
                  initialIndex: _index,
                  itemCount: _months.length,
                  wheelOptions: demoWheelOptions(demoStyle),
                  itemBuilder: (_, int index) => wheelText(_months[index]),
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
        ResultPanel(entries: [ResultEntry('selected month', _months[_index])]),
      ],
    );
  }
}
