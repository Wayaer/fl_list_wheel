import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:fl_list_wheel/src/date_time_extension.dart';
import 'package:flutter/material.dart';

part 'date.dart';

part 'date_time.dart';

part 'multi_list_wheel.dart';

part 'multi_list.dart';

part 'single_list.dart';

part 'single_list_wheel.dart';

/// 返回 false 不关闭弹窗;
typedef PickerTapCallback<T> = bool Function(T? value);

const double kPickerDefaultHeight = 180;

const double kPickerDefaultItemWidth = 90;

class PickerOptions<T> {
  const PickerOptions({
    this.top,
    this.cancel,
    this.title,
    this.confirm,
    this.bottom,
    this.bottomNavigationBar,
    this.titlePadding = const EdgeInsets.all(10),
    this.contentPadding,
    this.backgroundColor,
    this.background,
    this.decoration,
    this.verifyConfirm,
    this.verifyCancel,
  });

  /// 容器属性
  /// 整个Picker的背景色
  final Color? backgroundColor;

  /// 背景
  final Widget? background;

  /// [title]底部内容
  final Widget? bottom;

  /// bottom navigation bar
  final Widget? bottomNavigationBar;

  /// left
  final Widget? cancel;

  /// center
  final Widget? title;

  /// right
  final Widget? confirm;

  /// [title]顶部内容
  final Widget? top;

  /// [title]padding
  final EdgeInsetsGeometry titlePadding;

  /// 对内容
  final EdgeInsetsGeometry? contentPadding;

  /// 点击 [confirm] 后校验 [confirmTap] 数据，
  /// 返回 false 不关闭弹窗 默认 为 true;
  final PickerTapCallback<T>? verifyConfirm;

  /// 点击 [cancel] 后校验 [cancelTap] 数据，
  /// 返回 false 不关闭弹窗 默认 为 true;
  final PickerTapCallback<T>? verifyCancel;

  /// Decoration
  final Decoration? decoration;

  PickerOptions<T> copyWith({
    Decoration? decoration,
    Widget? background,
    Color? backgroundColor,
    Widget? bottom,
    Widget? top,
    Widget? title,
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry? contentPadding,
    Widget? bottomNavigationBar,
    Widget? confirm,
    PickerTapCallback<T>? verifyConfirm,
    Widget? cancel,
    PickerTapCallback<T>? verifyCancel,
  }) =>
      PickerOptions<T>(
          decoration: decoration ?? this.decoration,
          backgroundColor: backgroundColor ?? this.backgroundColor,
          bottom: bottom ?? this.bottom,
          top: top ?? this.top,
          titlePadding: titlePadding ?? this.titlePadding,
          contentPadding: contentPadding ?? this.contentPadding,
          title: title ?? this.title,
          confirm: confirm ?? this.confirm,
          cancel: cancel ?? this.cancel,
          background: background ?? this.background,
          verifyConfirm: verifyConfirm ?? this.verifyConfirm,
          verifyCancel: verifyCancel ?? this.verifyCancel,
          bottomNavigationBar: bottomNavigationBar ?? this.bottomNavigationBar);

  PickerOptions<T> merge(PickerOptions<T>? options) => copyWith(
      decoration: options?.decoration,
      backgroundColor: options?.backgroundColor,
      top: options?.top,
      bottom: options?.bottom,
      titlePadding: options?.titlePadding,
      contentPadding: options?.contentPadding,
      confirm: options?.confirm,
      cancel: options?.cancel,
      title: options?.title,
      background: options?.background,
      verifyConfirm: options?.verifyConfirm,
      verifyCancel: options?.verifyCancel,
      bottomNavigationBar: options?.bottomNavigationBar);
}

typedef PickerPositionIndexChanged = void Function(List<int> index);

typedef PickerPositionValueChanged<T> = void Function(List<T> value);

abstract class PickerStatelessWidget<T> extends StatelessWidget {
  const PickerStatelessWidget(
      {super.key,
      required this.options,
      required this.wheelOptions,
      this.height = kPickerDefaultHeight,
      this.width = double.infinity,
      this.itemWidth});

  /// 头部和背景色配置
  final PickerOptions<T>? options;

  /// Wheel配置信息
  final WheelOptions? wheelOptions;

  /// height
  final double height;

  /// width
  final double width;

  /// wheel width
  final double? itemWidth;
}

abstract class PickerStatefulWidget<T> extends StatefulWidget {
  const PickerStatefulWidget(
      {super.key,
      required this.options,
      required this.wheelOptions,
      this.height = kPickerDefaultHeight,
      this.width = double.infinity,
      this.itemWidth});

  /// 头部和背景色配置
  final PickerOptions<T>? options;

  /// Wheel配置信息
  final WheelOptions? wheelOptions;

  /// height
  final double height;

  /// width
  final double width;

  /// wheel width
  final double? itemWidth;
}

typedef PickerSubjectTapCallback<T> = T Function();

class PickerSubject<T> extends StatelessWidget {
  const PickerSubject({
    super.key,
    required this.options,
    required this.child,
    required this.confirmTap,
    this.cancelTap,
  });

  final PickerOptions<T> options;
  final Widget child;
  final PickerSubjectTapCallback<T>? confirmTap;
  final PickerSubjectTapCallback<T>? cancelTap;

  @override
  Widget build(BuildContext context) {
    final List<Widget> column = [];
    if (options.top != null) column.add(options.top!);
    if (options.cancel != null ||
        options.title != null ||
        options.confirm != null) {
      column.add(Padding(
        padding: options.titlePadding,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (options.cancel != null)
            GestureDetector(
                onTap: () {
                  final T? value = cancelTap?.call();
                  final bool isPop = options.verifyCancel?.call(value) ?? true;
                  if (isPop) FlListWheel.popFun.call(value);
                },
                child: options.cancel!),
          if (options.title != null) Expanded(child: options.title!),
          if (options.confirm != null)
            GestureDetector(
                onTap: () {
                  final T? value = confirmTap?.call();
                  final bool isPop = options.verifyConfirm?.call(value) ?? true;
                  if (isPop) FlListWheel.popFun.call(value);
                },
                child: options.confirm!),
        ]),
      ));
    }
    if (options.bottom != null) column.add(options.bottom!);
    Widget content = child;
    if (options.contentPadding != null) {
      content = Padding(padding: options.contentPadding!, child: content);
    }
    if (options.background != null) {
      content = Stack(children: [
        Positioned(
            left: 0, bottom: 0, right: 0, top: 0, child: options.background!),
        content,
      ]);
    }
    column.add(content);
    if (options.bottomNavigationBar != null) {
      column.add(options.bottomNavigationBar!);
    }

    return Container(
        decoration: options.decoration,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        color: options.backgroundColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: column));
  }
}

class _PickerListWheel extends FlListWheel {
  _PickerListWheel({
    ValueChanged<int>? onChanged,
    required super.itemCount,
    required super.itemBuilder,
    required super.options,
    super.controller,
    super.onScrollEnd,
  }) : super.builder(onSelectedItemChanged: onChanged);
}

extension ExtensionCustomPicker on CustomPicker {
  Future<T?> show<T>() async {
    final result = await FlListWheel.pushFun.call(this);
    return result is T ? result : null;
  }
}

class CustomPicker<T> extends PickerSubject<T> {
  const CustomPicker({
    super.key,
    required Widget content,

    /// 头部和背景色配置
    required super.options,

    /// 自定义 确定 按钮 返回参数
    super.confirmTap,

    /// 自定义 取消 按钮 返回参数
    super.cancelTap,
  }) : super(child: content);
}
