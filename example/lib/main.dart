import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

import 'package:example/src/home_page.dart';
import 'package:example/src/theme.dart';

void main() {
  runApp(const FlListWheelExampleApp());
}

class FlListWheelExampleApp extends StatefulWidget {
  const FlListWheelExampleApp({super.key});

  @override
  State<FlListWheelExampleApp> createState() => _FlListWheelExampleAppState();
}

class _FlListWheelExampleAppState extends State<FlListWheelExampleApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Picker.show() 依赖全局 presenter，在 App 启动时初始化一次即可
    FlListWheel.presenter = FlBottomSheetPickerPresenter(
      context: () => _navigatorKey.currentContext!,
      backgroundColor: Colors.transparent,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final ColorScheme colors = ColorScheme.fromSeed(seedColor: const Color(0xFF5B5BD6), brightness: brightness);
    final bool isDark = brightness == Brightness.dark;
    final Color background = isDark ? const Color(0xFF101014) : const Color(0xFFF6F6FA);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appThemeMode,
    builder: (_, ThemeMode mode, _) => MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FlListWheel',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: mode,
      home: const HomePage(),
    ),
  );
}
