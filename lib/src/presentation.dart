import 'package:flutter/material.dart';

/// 选择器展示器：负责打开选择器并等待结果。
/// 库内提供 [FlBottomSheetPickerPresenter]，也可以自行实现弹窗、对话框或全屏路由。
abstract class FlPickerPresenter {
  const FlPickerPresenter();

  /// 打开 [picker] 并返回结果；取消或直接关闭时返回 null。
  Future<T?> show<T>(Widget picker);
}

/// 使用 `showModalBottomSheet` 的默认展示器。
class FlBottomSheetPickerPresenter extends FlPickerPresenter {
  const FlBottomSheetPickerPresenter({
    required this.context,
    this.isScrollControlled = true,
    this.useRootNavigator = false,
    this.useSafeArea = false,
    this.backgroundColor,
    this.barrierColor,
    this.shape,
  });

  /// 返回有效 context 的方法，通常是 `navigatorKey.currentContext`。
  final BuildContext Function() context;

  /// 弹窗高度是否允许超过半屏，默认 true。
  final bool isScrollControlled;

  /// 是否使用根 Navigator，默认 false（从最近的 Navigator 弹出）。
  final bool useRootNavigator;

  /// 是否避让系统安全区，默认 false（与 `showModalBottomSheet` 一致）。
  final bool useSafeArea;

  /// 弹窗背景色；为 null 时使用主题默认值。
  final Color? backgroundColor;

  /// 遮罩颜色。
  final Color? barrierColor;

  /// 弹窗形状，例如顶部圆角。
  final ShapeBorder? shape;

  @override
  Future<T?> show<T>(Widget picker) {
    final BuildContext current = context();
    if (!current.mounted) {
      throw FlutterError('FlBottomSheetPickerPresenter context is no longer mounted.');
    }
    return showModalBottomSheet<T>(
      context: current,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      shape: shape,
      builder: (BuildContext routeContext) =>
          FlPickerSession<T>(close: (T? value) => Navigator.of(routeContext).pop<T>(value), child: picker),
    );
  }
}

/// 把“关闭当前选择器并回传结果”的能力传给具体 Picker。
/// 由 [FlPickerPresenter] 在打开选择器时自动包裹，内联使用时可以自行包裹。
class FlPickerSession<T> extends InheritedWidget {
  const FlPickerSession({super.key, required this.close, required super.child});

  /// 关闭当前弹窗并回传结果。
  final void Function(T? value) close;

  /// 获取最近的会话；内联使用时返回 null。
  static FlPickerSession<T>? maybeOf<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FlPickerSession<T>>();

  @override
  bool updateShouldNotify(FlPickerSession<T> oldWidget) => false;
}
