import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

class SingleListDemoPage extends StatefulWidget {
  const SingleListDemoPage({super.key});

  @override
  State<SingleListDemoPage> createState() => _SingleListDemoPageState();
}

class _SingleListDemoPageState extends State<SingleListDemoPage> {
  static final List<String> _values = List.generate(24, (int index) => 'Item ${twoDigits(index + 1)}');

  bool _multiple = true;

  List<int> _selected = const [2, 5];

  FlSingleListPickerOptions get _pickerOptions => FlSingleListPickerOptions(allowedMultipleChoice: _multiple);

  void _onChanged(List<int> index) => setState(() => _selected = index);

  Widget _grid(int itemCount, IndexedWidgetBuilder itemBuilder) => GridView.builder(
    padding: const EdgeInsets.all(10),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 120,
      mainAxisExtent: 44,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
    ),
    itemBuilder: itemBuilder,
    itemCount: itemCount,
  );

  Widget _tile(BuildContext context, int index, bool isSelect, FlSelectIndexedChangedFunction change) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelect ? colors.primary : colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _values[index],
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelect ? colors.onPrimary : colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _showPicker() async {
    final List<int>? result = await FlSingleListPicker(
      itemCount: _values.length,
      initialIndex: _selected,
      options: demoPickerOptions<List<int>>(context, title: 'Select items'),
      singleListPickerOptions: _pickerOptions,
      builder: _grid,
      itemBuilder: _tile,
      onChanged: _onChanged,
    ).show();
    if (!mounted) return;
    if (result != null) _onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Single list',
      subtitle: '普通列表多选 / 单选，可替换为 GridView 等任意列表布局。',
      children: [
        DemoSection(
          title: 'Selection mode',
          component: 'FlSingleListPickerOptions',
          code: 'FlSingleListPickerOptions(allowedMultipleChoice: false)',
          child: DemoChoices<bool>(
            choices: const [DemoChoice(true, 'Multiple choice'), DemoChoice(false, 'Single choice')],
            selected: _multiple,
            onChanged: (bool value) => setState(() => _multiple = value),
          ),
        ),
        DemoSection(
          title: 'Preview',
          subtitle: '点击卡片切换选中状态。',
          component: 'FlSingleListPicker',
          code: 'FlSingleListPicker(itemCount: 6, itemBuilder: ...).show()',
          child: SizedBox(
            height: 300,
            child: FlSingleListPicker(
              itemCount: _values.length,
              initialIndex: _selected,
              singleListPickerOptions: _pickerOptions,
              builder: _grid,
              itemBuilder: _tile,
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
        ResultPanel(
          entries: [
            ResultEntry('count', '${_selected.length}'),
            ResultEntry('items', _selected.isEmpty ? null : _selected.map((int index) => _values[index]).join(' / ')),
          ],
        ),
      ],
    );
  }
}
