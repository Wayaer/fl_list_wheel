import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

class CustomPickerDemoPage extends StatefulWidget {
  const CustomPickerDemoPage({super.key});

  @override
  State<CustomPickerDemoPage> createState() => _CustomPickerDemoPageState();
}

class _CustomPickerDemoPageState extends State<CustomPickerDemoPage> {
  static const List<String> _options = ['Indigo', 'Emerald', 'Amber', 'Rose', 'Slate'];

  static const Map<String, Color> _colors = {
    'Indigo': Color(0xFF5B5BD6),
    'Emerald': Color(0xFF10B981),
    'Amber': Color(0xFFF59E0B),
    'Rose': Color(0xFFF43F5E),
    'Slate': Color(0xFF64748B),
  };

  String? _value;

  Future<void> _openPicker() async {
    String selected = _value ?? _options.first;
    final String? result = await FlCustomPicker<String>(
      options: demoPickerOptions<String>(context, title: 'Pick a color'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final String option in _options)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: _colors[option], radius: 8),
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => setSheetState(() => selected = option),
                ),
            ],
          ),
        ),
      ),
      confirmTap: () => selected,
    ).show();
    if (!mounted) return;
    if (result != null) setState(() => _value = result);
  }

  @override
  Widget build(BuildContext context) {
    final Color? color = _value == null ? null : _colors[_value];
    return DemoScaffold(
      title: 'Custom picker',
      subtitle: 'FlCustomPicker 只负责头部和确认 / 取消逻辑，内容区域完全由你决定。',
      children: [
        DemoSection(
          title: 'Content',
          subtitle: '传入任意 Widget 作为内容，确认时返回自定义值。',
          component: 'FlCustomPicker',
          code: 'FlCustomPicker<String>(content: ..., confirmTap: () => value).show()',
          child: Center(
            child: Container(
              height: 180,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _value ?? 'No color selected',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openPicker,
            icon: const Icon(Icons.widgets_outlined),
            label: const Text('Open custom picker'),
          ),
        ),
        const SizedBox(height: 16),
        ResultPanel(entries: [ResultEntry('selected color', _value)]),
      ],
    );
  }
}
