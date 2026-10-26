import 'package:flutter/material.dart';

import 'package:example/src/demos/area_demo.dart';
import 'package:example/src/demos/custom_picker_demo.dart';
import 'package:example/src/demos/date_picker_demo.dart';
import 'package:example/src/demos/date_time_picker_demo.dart';
import 'package:example/src/demos/multi_list_linkage_demo.dart';
import 'package:example/src/demos/multi_list_wheel_demo.dart';
import 'package:example/src/demos/multi_list_wheel_linkage_demo.dart';
import 'package:example/src/demos/presentation_demo.dart';
import 'package:example/src/demos/single_list_demo.dart';
import 'package:example/src/demos/single_list_wheel_demo.dart';
import 'package:example/src/demos/wheel_demo.dart';
import 'package:example/src/theme.dart';

class DemoEntry {
  const DemoEntry({required this.title, required this.subtitle, required this.icon, required this.builder});

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

final List<DemoEntry> _wheelDemos = [
  DemoEntry(
    title: 'List wheel',
    subtitle: 'FlListWheel 与 FlListWheelState，Cupertino / Material 两种样式',
    icon: Icons.unfold_more,
    builder: (_) => const WheelDemoPage(),
  ),
];

final List<DemoEntry> _pickerDemos = [
  DemoEntry(
    title: 'Date picker',
    subtitle: '年月日联动，支持只显示部分单位',
    icon: Icons.event_outlined,
    builder: (_) => const DatePickerDemoPage(),
  ),
  DemoEntry(
    title: 'Date & time picker',
    subtitle: '自由组合年月日时分秒滚轮',
    icon: Icons.schedule_outlined,
    builder: (_) => const DateTimePickerDemoPage(),
  ),
  DemoEntry(
    title: 'Area picker',
    subtitle: '省 / 市 / 区三级联动',
    icon: Icons.location_on_outlined,
    builder: (_) => const AreaDemoPage(),
  ),
  DemoEntry(
    title: 'Multi-column wheel',
    subtitle: '多列滚轮，互不联动',
    icon: Icons.view_week_outlined,
    builder: (_) => const MultiListWheelDemoPage(),
  ),
  DemoEntry(
    title: 'Linked wheel',
    subtitle: '多列滚轮联动，数据随选择变化',
    icon: Icons.account_tree_outlined,
    builder: (_) => const MultiListWheelLinkageDemoPage(),
  ),
  DemoEntry(
    title: 'Linked list',
    subtitle: '非滚轮的多列联动列表',
    icon: Icons.list_alt_outlined,
    builder: (_) => const MultiListLinkageDemoPage(),
  ),
  DemoEntry(
    title: 'Single list',
    subtitle: '列表多选 / 单选，可替换任意布局',
    icon: Icons.checklist_outlined,
    builder: (_) => const SingleListDemoPage(),
  ),
  DemoEntry(
    title: 'Single wheel',
    subtitle: '单列滚轮，适合枚举与数量',
    icon: Icons.view_carousel_outlined,
    builder: (_) => const SingleListWheelDemoPage(),
  ),
  DemoEntry(
    title: 'Custom picker',
    subtitle: '自定义内容 + 确认 / 取消逻辑',
    icon: Icons.widgets_outlined,
    builder: (_) => const CustomPickerDemoPage(),
  ),
  DemoEntry(
    title: 'Presentation',
    subtitle: '全局 presenter / Cupertino popup / 内联 FlPickerSession',
    icon: Icons.layers_outlined,
    builder: (_) => const PresentationDemoPage(),
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            titleSpacing: 20,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(11)),
                  child: Icon(Icons.unfold_more, size: 20, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
                const Text('FlListWheel', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
            actions: const [ThemeModeButton(), SizedBox(width: 8)],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            sliver: SliverToBoxAdapter(child: _HeroCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Wheel', count: _wheelDemos.length),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 420,
                mainAxisExtent: 108,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => _DemoCard(entry: _wheelDemos[index]),
                childCount: _wheelDemos.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: _SectionTitle(title: 'Pickers', count: _pickerDemos.length),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 420,
                mainAxisExtent: 108,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => _DemoCard(entry: _pickerDemos[index]),
                childCount: _pickerDemos.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Text(
                    'Bottom sheet 示例使用 FlListWheel.presenter，已在 main.dart 中初始化。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'github.com/Wayaer/fl_list_wheel',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x334F46E5), blurRadius: 28, offset: Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 28),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Every wheel, one package.',
            style: TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'Extended ListWheelScrollView & CupertinoPicker, plus date, time, area and linkage pickers.',
            style: TextStyle(fontSize: 13.5, height: 1.5, color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroTag(icon: Icons.flutter_dash, text: 'Flutter 3.47'),
              _HeroTag(icon: Icons.code, text: 'Dart 3.13'),
              _HeroTag(icon: Icons.sell_outlined, text: 'v1.0.0'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(999)),
          child: Text(
            '$count',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onPrimaryContainer),
          ),
        ),
      ],
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.entry});

  final DemoEntry entry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: entry.builder)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(14)),
                child: Icon(entry.icon, size: 22, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, height: 1.35, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: colors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
