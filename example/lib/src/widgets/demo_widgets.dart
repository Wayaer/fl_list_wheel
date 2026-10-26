import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/theme.dart';

String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatDate(DateTime value) => '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)}';

String formatDateTime(DateTime value) =>
    '${formatDate(value)} ${twoDigits(value.hour)}:${twoDigits(value.minute)}:${twoDigits(value.second)}';

/// 页面级外壳：统一标题、宽度和滚动行为
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({super.key, required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [ThemeModeButton(), SizedBox(width: 8)],
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              children: [
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(subtitle!, style: TextStyle(fontSize: 14, height: 1.5, color: colors.onSurfaceVariant)),
                  ),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 带标题的卡片容器
class DemoSection extends StatelessWidget {
  const DemoSection({
    super.key,
    this.title,
    this.subtitle,
    this.component,
    this.code,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
    required this.child,
  });

  final String? title;
  final String? subtitle;

  /// 该示例使用的组件类名，显示在卡片顶部
  final String? component;

  /// 简短的代码用法，显示在标题下方
  final String? code;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool hasHeader = title != null || trailing != null || subtitle != null || component != null || code != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(alignment: Alignment.centerLeft, child: _ComponentBadge(component!)),
            ),
          if (title != null || trailing != null)
            Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Text(title!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ?trailing,
              ],
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(subtitle!, style: TextStyle(fontSize: 12.5, height: 1.45, color: colors.onSurfaceVariant)),
            ),
          if (code != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Text(
                  code!,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4, color: colors.onSurface),
                ),
              ),
            ),
          if (hasHeader) const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// 组件类名徽标
class _ComponentBadge extends StatelessWidget {
  const _ComponentBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}

class ResultEntry {
  const ResultEntry(this.label, this.value);

  final String label;
  final String? value;
}

/// 统一的回显面板
class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    this.entries = const [],
    this.placeholder = 'Interact with a wheel or open the bottom sheet.',
  });

  final List<ResultEntry> entries;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool hasValue = entries.any((ResultEntry entry) => entry.value != null);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Result',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasValue)
            Text(placeholder, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant))
          else
            for (final ResultEntry entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 112,
                      child: Text(entry.label, style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant)),
                    ),
                    Expanded(
                      child: Text(
                        entry.value ?? '—',
                        style: const TextStyle(fontSize: 13.5, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class DemoChoice<T> {
  const DemoChoice(this.value, this.label);

  final T value;
  final String label;
}

/// 自适应换行的选择器（比 SegmentedButton 更适合窄屏）
class DemoChoices<T> extends StatelessWidget {
  const DemoChoices({super.key, required this.choices, required this.selected, required this.onChanged});

  final List<DemoChoice<T>> choices;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final DemoChoice<T> choice in choices)
        ChoiceChip(
          label: Text(choice.label),
          selected: selected == choice.value,
          showCheckmark: false,
          onSelected: (_) => onChanged(choice.value),
        ),
    ],
  );
}

/// 打开底部弹窗时使用的统一外观
FlPickerOptions<T> demoPickerOptions<T>(BuildContext context, {required String title}) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  final TextStyle actionStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary);
  return FlPickerOptions<T>(
    backgroundColor: colors.surface,
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    titlePadding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
    contentPadding: const EdgeInsets.only(bottom: 8),
    top: Center(
      child: Container(
        width: 44,
        height: 4,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(color: colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
      ),
    ),
    title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    cancel: Text('Cancel', style: actionStyle),
    confirm: Text('Done', style: actionStyle),
  );
}

Widget wheelText(String text, {TextStyle? style}) => Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    ),
  ),
);

enum DemoWheelStyle { cupertino, material }

const List<DemoChoice<DemoWheelStyle>> demoWheelStyleChoices = [
  DemoChoice(DemoWheelStyle.cupertino, 'Cupertino'),
  DemoChoice(DemoWheelStyle.material, 'Material'),
];

/// 示例统一使用更高的行高并降低放大倍率，避免文字在滚动边缘被裁切。
/// 渲染风格由全局配置决定，局部配置只负责行高、放大倍率等参数。
FlWheelOptions demoWheelOptions(DemoWheelStyle style) => style == DemoWheelStyle.cupertino
    ? const FlWheelOptions.cupertino(itemExtent: 36, magnification: 1.05)
    : const FlWheelOptions(itemExtent: 36, magnification: 1.1);

/// 把全局滚轮风格切换为 [style]。
/// 只在页面初始化和用户切换风格时调用，避免在 build 中修改全局状态。
void applyDemoWheelStyle(DemoWheelStyle style) {
  FlListWheel.wheelOptions = style == DemoWheelStyle.cupertino
      ? const FlWheelOptions.cupertino()
      : const FlWheelOptions();
}

/// 示例页面共用的滚轮风格状态：初始化与切换时同步全局配置
mixin DemoWheelStyleState<T extends StatefulWidget> on State<T> {
  /// 当前示例使用的滚轮风格
  DemoWheelStyle demoStyle = DemoWheelStyle.cupertino;

  @override
  void initState() {
    super.initState();
    applyDemoWheelStyle(demoStyle);
  }

  /// 切换滚轮风格并刷新页面
  void changeDemoStyle(DemoWheelStyle value) {
    if (value == demoStyle) return;
    applyDemoWheelStyle(value);
    setState(() => demoStyle = value);
  }
}
