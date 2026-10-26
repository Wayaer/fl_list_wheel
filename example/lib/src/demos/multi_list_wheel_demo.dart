import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

class MultiListWheelDemoPage extends StatefulWidget {
  const MultiListWheelDemoPage({super.key});

  @override
  State<MultiListWheelDemoPage> createState() => _MultiListWheelDemoPageState();
}

class _MultiListWheelDemoPageState extends State<MultiListWheelDemoPage>
    with DemoWheelStyleState<MultiListWheelDemoPage> {
  static const List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const List<String> _symbols = ['★', '●', '▲', '■', '◆', '♥'];

  static final List<String> _numbers = List.generate(12, (int index) => twoDigits(index + 1));

  late final List<FlPickerItem> _columns = [
    FlPickerItem(itemCount: _letters.length, itemBuilder: (_, int index) => wheelText(_letters[index])),
    FlPickerItem(itemCount: _numbers.length, itemBuilder: (_, int index) => wheelText(_numbers[index])),
    FlPickerItem(itemCount: _symbols.length, itemBuilder: (_, int index) => wheelText(_symbols[index])),
  ];

  List<int> _position = const [2, 4, 1];

  String get _label => '${_letters[_position[0]]} / ${_numbers[_position[1]]} / ${_symbols[_position[2]]}';

  void _onChanged(List<int> index) => setState(() => _position = index);

  Future<void> _showPicker() async {
    final List<int>? result = await FlMultiListWheelPicker(
      items: _columns,
      value: _position,
      height: 260,
      wheelOptions: demoWheelOptions(demoStyle),
      options: demoPickerOptions<List<int>>(context, title: 'Select columns'),
      onChanged: _onChanged,
    ).show();
    if (!mounted) return;
    if (result != null) _onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Multi-column wheel',
      subtitle: '多列滚轮互不联动，每列都可以独立设置数据源和 itemBuilder。',
      children: [
        DemoSection(
          title: 'Preview',
          subtitle: _label,
          component: 'FlMultiListWheelPicker',
          code: 'FlMultiListWheelPicker(items: columns).show()',
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
                height: 260,
                child: FlMultiListWheelPicker(
                  items: _columns,
                  value: _position,
                  height: 260,
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
        ResultPanel(
          entries: [
            ResultEntry('letter', _letters[_position[0]]),
            ResultEntry('number', _numbers[_position[1]]),
            ResultEntry('symbol', _symbols[_position[2]]),
          ],
        ),
      ],
    );
  }
}
