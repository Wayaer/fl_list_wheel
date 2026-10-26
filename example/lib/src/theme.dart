import 'package:flutter/material.dart';

/// 示例 App 的全局主题模式，默认跟随系统
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

/// 循环切换：跟随系统 -> 黑夜 -> 白天 -> 跟随系统
ThemeMode nextThemeMode(ThemeMode mode) => switch (mode) {
  ThemeMode.system => ThemeMode.dark,
  ThemeMode.dark => ThemeMode.light,
  ThemeMode.light => ThemeMode.system,
};

IconData themeModeIcon(ThemeMode mode) => switch (mode) {
  ThemeMode.system => Icons.brightness_auto_outlined,
  ThemeMode.light => Icons.light_mode_outlined,
  ThemeMode.dark => Icons.dark_mode_outlined,
};

/// 各页面通用的白天 / 黑夜切换按钮
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appThemeMode,
    builder: (_, ThemeMode mode, _) => IconButton(
      tooltip: 'Switch theme',
      onPressed: () => appThemeMode.value = nextThemeMode(mode),
      icon: Icon(themeModeIcon(mode)),
    ),
  );
}
