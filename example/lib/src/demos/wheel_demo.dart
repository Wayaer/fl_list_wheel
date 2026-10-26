import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

class WheelDemoPage extends StatefulWidget {
  const WheelDemoPage({super.key});

  @override
  State<WheelDemoPage> createState() => _WheelDemoPageState();
}

class _WheelDemoPageState extends State<WheelDemoPage> with DemoWheelStyleState<WheelDemoPage> {
  static const List<String> _values = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];

  final FixedExtentScrollController _controller = FixedExtentScrollController(initialItem: 4);

  int _builderIndex = 0;
  int _stateIndex = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    _controller.animateToItem(index, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'List wheel',
      subtitle: 'FlListWheel 统一封装了 ListWheelScrollView 与 CupertinoPicker；FlListWheelState 可以管理 controller 的创建与释放。',
      children: [
        DemoSection(
          title: 'Wheel style',
          component: 'FlWheelOptions',
          code: 'FlListWheel.wheelOptions = const FlWheelOptions.cupertino()',
          child: DemoChoices<DemoWheelStyle>(
            choices: const [
              DemoChoice(DemoWheelStyle.cupertino, 'Cupertino'),
              DemoChoice(DemoWheelStyle.material, 'Material'),
            ],
            selected: demoStyle,
            onChanged: changeDemoStyle,
          ),
        ),
        DemoSection(
          title: 'FlListWheel.builder',
          subtitle: '按需构建子项，适合数据量较大的列表。',
          component: 'FlListWheel',
          code: 'FlListWheel.builder(itemCount: 10, itemBuilder: ...)',
          child: SizedBox(
            height: 240,
            child: FlListWheel.builder(
              options: demoWheelOptions(demoStyle),
              onSelectedItemChanged: (int index) => setState(() => _builderIndex = index),
              itemBuilder: (_, int index) => wheelText(_values[index]),
              itemCount: _values.length,
            ),
          ),
        ),
        DemoSection(
          title: 'FlListWheel.count + FlListWheelState',
          subtitle: '使用外部 controller 控制选中项，FlListWheelState 只负责把 controller 传入 builder。',
          component: 'FlListWheelState',
          code: 'FlListWheelState(count: 10, builder: (controller) => FlListWheel.count(...))',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Jump to first',
                onPressed: () => _jumpTo(0),
                icon: const Icon(Icons.keyboard_double_arrow_up),
              ),
              IconButton(
                tooltip: 'Jump to last',
                onPressed: () => _jumpTo(_values.length - 1),
                icon: const Icon(Icons.keyboard_double_arrow_down),
              ),
            ],
          ),
          child: SizedBox(
            height: 240,
            child: FlListWheelState(
              controller: _controller,
              count: _values.length,
              initialItem: 4,
              builder: (FixedExtentScrollController controller) => FlListWheel.count(
                controller: controller,
                options: demoWheelOptions(demoStyle),
                onSelectedItemChanged: (int index) => setState(() => _stateIndex = index),
                children: [for (final String value in _values) wheelText(value)],
              ),
            ),
          ),
        ),
        ResultPanel(
          entries: [
            ResultEntry('builder', '${_builderIndex + 1} · ${_values[_builderIndex]}'),
            ResultEntry('count + state', '${_stateIndex + 1} · ${_values[_stateIndex]}'),
          ],
        ),
      ],
    );
  }
}
