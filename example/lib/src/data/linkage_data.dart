import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

/// 示例数据：用于“多列联动”演示
const Map<String, dynamic> deviceCatalog = {
  'Phone': {
    'Pro': ['Pro 6.1"', 'Pro 6.7"', 'Pro Max'],
    'Standard': ['Mini', 'Plus', 'Standard'],
  },
  'Tablet': {
    'Air': ['Air 11"', 'Air 13"'],
    'Pro': ['Pro 11"', 'Pro 13"'],
  },
  'Watch': {
    'Sport': ['40 mm', '44 mm'],
    'Ultra': ['49 mm'],
  },
};

Widget wheelLabel(String text, TextStyle? style) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
);

/// 把嵌套 Map/List 转换成滚轮联动数据
/// [maxDepth] 限制联动层级数，超过后不再生成下一列
List<FlPickerLinkageItem<String>> buildWheelLinkageItems(
  Map<String, dynamic> source, {
  TextStyle? textStyle,
  int? maxDepth,
}) {
  List<FlPickerLinkageItem<String>> build(Map<String, dynamic> map, int depth) {
    final List<FlPickerLinkageItem<String>> result = [];
    for (final MapEntry<String, dynamic> entry in map.entries) {
      final dynamic value = entry.value;
      List<FlPickerLinkageItem<String>> children = const [];
      if (maxDepth == null || depth < maxDepth) {
        if (value is Map<String, dynamic>) {
          children = build(value, depth + 1);
        } else if (value is List<dynamic>) {
          children = [
            for (final dynamic item in value)
              FlPickerLinkageItem<String>(value: item.toString(), child: wheelLabel(item.toString(), textStyle)),
          ];
        }
      }
      result.add(
        FlPickerLinkageItem<String>(value: entry.key, child: wheelLabel(entry.key, textStyle), children: children),
      );
    }
    return result;
  }

  return build(source, 1);
}

Widget listLinkageLabel(String text) => Builder(
  builder: (BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onPrimaryContainer),
      ),
    );
  },
);

/// 把嵌套 Map/List 转换成普通列表联动数据
List<FlPickerListLinkageItem<String>> buildListLinkageItems(Map<String, dynamic> source) {
  List<FlPickerListLinkageItem<String>> build(Map<String, dynamic> map) {
    final List<FlPickerListLinkageItem<String>> result = [];
    for (final MapEntry<String, dynamic> entry in map.entries) {
      final dynamic value = entry.value;
      List<FlPickerListLinkageItem<String>> children = const [];
      if (value is Map<String, dynamic>) {
        children = build(value);
      } else if (value is List<dynamic>) {
        children = [
          for (final dynamic item in value)
            FlPickerListLinkageItem<String>(
              value: item.toString(),
              child: (bool selected) => Opacity(opacity: selected ? 1 : 0.55, child: listLinkageLabel(item.toString())),
            ),
        ];
      }
      result.add(
        FlPickerListLinkageItem<String>(
          value: entry.key,
          child: (bool selected) => Opacity(opacity: selected ? 1 : 0.55, child: listLinkageLabel(entry.key)),
          children: children,
        ),
      );
    }
    return result;
  }

  return build(source);
}

/// 根据位置下标还原选中的值
List<String> resolveLinkageValues<T>(List<FlPickerLinkageItem<T>> items, List<int> positions) {
  final List<String> values = [];
  List<FlPickerLinkageItem<T>> current = items;
  for (final int index in positions) {
    if (index < 0 || index >= current.length) break;
    final FlPickerLinkageItem<T> item = current[index];
    values.add(item.value.toString());
    current = item.children;
  }
  return values;
}

/// 根据位置下标还原选中的值（普通列表联动）
List<String> resolveListLinkageValues<T>(List<FlPickerListLinkageItem<T>> items, List<int> positions) {
  final List<String> values = [];
  List<FlPickerListLinkageItem<T>> current = items;
  for (final int index in positions) {
    if (index < 0 || index >= current.length) break;
    final FlPickerListLinkageItem<T> item = current[index];
    values.add(item.value.toString());
    current = item.children;
  }
  return values;
}
