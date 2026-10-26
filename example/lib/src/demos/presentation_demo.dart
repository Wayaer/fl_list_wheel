import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:example/src/widgets/demo_widgets.dart';

/// 用 Cupertino 模态弹窗展示选择器
class _CupertinoModalPresenter extends FlPickerPresenter {
  const _CupertinoModalPresenter({required this.context});

  final BuildContext Function() context;

  @override
  Future<T?> show<T>(Widget picker) => showCupertinoModalPopup<T>(
    context: context(),
    builder: (BuildContext routeContext) =>
        FlPickerSession<T>(close: (T? value) => Navigator.of(routeContext).pop<T>(value), child: picker),
  );
}

class PresentationDemoPage extends StatefulWidget {
  const PresentationDemoPage({super.key});

  @override
  State<PresentationDemoPage> createState() => _PresentationDemoPageState();
}

class _PresentationDemoPageState extends State<PresentationDemoPage> {
  static const List<String> _values = ['Alpha', 'Bravo', 'Charlie', 'Delta', 'Echo', 'Foxtrot'];

  int _index = 2;

  String get _label => _values[_index];

  void _applyResult(int? result) {
    if (result == null || !mounted) return;
    setState(() => _index = result);
  }

  FlSingleListWheelPicker _buildPicker(FlPickerOptions<int> options) => FlSingleListWheelPicker(
    initialIndex: _index,
    itemCount: _values.length,
    height: 200,
    itemBuilder: (BuildContext context, int index) => wheelText(_values[index]),
    options: options,
  );

  Future<void> _showGlobalSheet() async {
    final int? result = await _buildPicker(demoPickerOptions<int>(context, title: 'Global presenter')).show();
    _applyResult(result);
  }

  Future<void> _showCupertinoPopup() async {
    final int? result = await _buildPicker(demoPickerOptions<int>(context, title: 'Cupertino presenter'))
        .show(presenter: _CupertinoModalPresenter(context: () => context));
    _applyResult(result);
  }

  Future<void> _showInlineDialog() async {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: 320,
          child: FlPickerSession<int>(
            close: (int? value) => Navigator.of(dialogContext).pop(value),
            child: _buildPicker(
              FlPickerOptions<int>(
                backgroundColor: colors.surface,
                decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(22)),
                title: const Text('Inline dialog'),
                cancel: const Text('Cancel'),
                confirm: const Text('Done'),
              ),
            ),
          ),
        ),
      ),
    );
    _applyResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Presentation',
      subtitle: '同一个选择器可以走全局 presenter、单次自定义 presenter，或放进自己的 Dialog 并包裹 FlPickerSession。',
      children: [
        DemoSection(
          title: 'Current value',
          subtitle: _label,
          component: 'FlPickerPresenter',
          code: 'FlListWheel.presenter = FlBottomSheetPickerPresenter(context: ...)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: _showGlobalSheet,
                icon: const Icon(Icons.vertical_align_bottom),
                label: const Text('Global bottom sheet'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _showCupertinoPopup,
                icon: const Icon(Icons.phone_iphone),
                label: const Text('Cupertino popup'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _showInlineDialog,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Inline dialog + FlPickerSession'),
              ),
            ],
          ),
        ),
        ResultPanel(entries: [ResultEntry('selection', _label)]),
      ],
    );
  }
}
