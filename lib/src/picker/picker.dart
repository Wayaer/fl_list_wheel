import 'package:fl_list_wheel/src/date_time_extension.dart';
import 'package:fl_list_wheel/src/fl_list_wheel.dart';
import 'package:fl_list_wheel/src/options.dart';
import 'package:fl_list_wheel/src/presentation.dart';
import 'package:flutter/material.dart';

part 'date.dart';

part 'date_time.dart';

part 'multi_list_wheel.dart';

part 'multi_list.dart';

part 'single_list.dart';

part 'single_list_wheel.dart';

/// 点击取消/确认时的校验回调，返回 false 时不关闭弹窗
typedef FlPickerTapCallback<T> = bool Function(T? value);

/// 选择器默认高度
const double kPickerDefaultHeight = 180;

/// 横向滚动时单列滚轮的默认宽度
const double kPickerDefaultItemWidth = 90;

bool _equalsList<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// 校正日期选择器的区间：结束日期必须晚于开始日期，默认日期收敛到区间内
({DateTime start, DateTime defaultDate, DateTime end}) _normalizeDateRange({
  required DateTime startDate,
  required DateTime defaultDate,
  required DateTime endDate,
}) {
  final DateTime start = startDate;
  final DateTime end = start.isBefore(endDate) ? endDate : start.add(const Duration(days: 1));
  final DateTime safeDefault = defaultDate.isBefore(start) ? start : (defaultDate.isAfter(end) ? end : defaultDate);
  return (start: start, defaultDate: safeDefault, end: end);
}

/// 记录上一次已通知的选择路径，避免相同结果重复触发回调
class _FlPickerPositionTracker {
  List<int> last = const [];

  /// [next] 与上次不同时记录并返回 true
  bool isChanged(List<int> next) {
    if (_equalsList(last, next)) return false;
    last = [...next];
    return true;
  }
}

/// 选择器的头部、背景等通用配置。
/// [options] 为 null 时只渲染滚轮内容，不显示取消/标题/确认栏。
class FlPickerOptions<T> {
  const FlPickerOptions({
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

  /// 整体背景色；与 [decoration] 同时设置时以 [decoration] 为准
  final Color? backgroundColor;

  /// 铺在内容下层的背景组件
  final Widget? background;

  /// 标题栏下方的自定义内容
  final Widget? bottom;

  /// 内容下方的底部导航栏
  final Widget? bottomNavigationBar;

  /// 左侧取消按钮，点击后通过 [verifyCancel] 决定是否关闭
  final Widget? cancel;

  /// 中间标题
  final Widget? title;

  /// 右侧确认按钮，点击后通过 [verifyConfirm] 决定是否关闭
  final Widget? confirm;

  /// 标题栏上方的自定义内容
  final Widget? top;

  /// 标题栏内边距
  final EdgeInsetsGeometry titlePadding;

  /// 滚轮内容的内边距
  final EdgeInsetsGeometry? contentPadding;

  /// 点击 [confirm] 后的校验回调，返回 false 不关闭弹窗，默认允许关闭
  final FlPickerTapCallback<T>? verifyConfirm;

  /// 点击 [cancel] 后的校验回调，返回 false 不关闭弹窗，默认允许关闭
  final FlPickerTapCallback<T>? verifyCancel;

  /// 容器装饰；设置后忽略 [backgroundColor]
  final Decoration? decoration;

  /// 复制并替换部分参数；传 null 表示保留当前值，
  /// 因此无法通过 copyWith 把可空字段重置回 null，需要时请直接构造新实例
  FlPickerOptions<T> copyWith({
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
    FlPickerTapCallback<T>? verifyConfirm,
    Widget? cancel,
    FlPickerTapCallback<T>? verifyCancel,
  }) => FlPickerOptions<T>(
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
    bottomNavigationBar: bottomNavigationBar ?? this.bottomNavigationBar,
  );

  /// 以当前配置为默认值，用 [options] 中非 null 的项覆盖
  FlPickerOptions<T> merge(FlPickerOptions<T>? options) => copyWith(
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
    bottomNavigationBar: options?.bottomNavigationBar,
  );
}

/// 选择位置变化回调，参数为每一列当前选中的下标
typedef FlPickerPositionIndexChanged = void Function(List<int> index);

/// 选择内容变化回调，参数为每一列当前选中的值
typedef FlPickerPositionValueChanged<T> = void Function(List<T> value);

/// 选择器的有状态公共基类，统一管理头部配置、尺寸和滚轮配置
abstract class FlPickerStatefulWidget<T> extends StatefulWidget {
  const FlPickerStatefulWidget({
    super.key,
    required this.options,
    required this.wheelOptions,
    this.height = kPickerDefaultHeight,
    this.width = double.infinity,
    this.itemWidth,
  });

  /// 头部与背景配置；为 null 时不显示头部
  final FlPickerOptions<T>? options;

  /// 滚轮样式与滚动参数
  final FlWheelOptions? wheelOptions;

  /// 选择器高度
  final double height;

  /// 选择器宽度
  final double width;

  /// 每一列的宽度；为 null 时按具体选择器规则占满、均分或使用默认宽度
  final double? itemWidth;
}

/// 点击按钮时取值的方法；返回 null 表示当前没有可选结果，弹窗按取消处理
typedef FlPickerSubjectTapCallback<T> = T? Function();

/// 选择器统一头部容器：负责取消/标题/确认的布局与结果回传。
/// 只有弹窗路由会自动关闭，内联使用时仅触发回调，避免误 pop 页面。
class FlPickerSubject<T> extends StatelessWidget {
  const FlPickerSubject({
    super.key,
    required this.options,
    required this.child,
    required this.confirmTap,
    this.cancelTap,
  });

  /// 头部与背景配置
  final FlPickerOptions<T> options;

  /// 取消/标题/确认栏下方的内容
  final Widget child;

  /// 点击确认时取值的方法，返回值即弹窗结果
  final FlPickerSubjectTapCallback<T>? confirmTap;

  /// 点击取消时取值的方法，默认返回 null
  final FlPickerSubjectTapCallback<T>? cancelTap;

  void _tap(BuildContext context, T? value, FlPickerTapCallback<T>? verify) {
    final bool shouldClose = verify?.call(value) ?? true;
    if (!shouldClose) return;
    // 由 presenter 包裹时才有 session；内联使用时不关闭任何路由
    FlPickerSession.maybeOf<T>(context)?.close(value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> column = [];
    if (options.top != null) column.add(options.top!);
    if (options.cancel != null || options.title != null || options.confirm != null) {
      column.add(
        Padding(
          padding: options.titlePadding,
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: options.cancel == null
                      ? null
                      : Semantics(
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _tap(context, cancelTap?.call(), options.verifyCancel),
                            child: options.cancel!,
                          ),
                        ),
                ),
              ),
              Expanded(flex: 3, child: Center(child: options.title)),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: options.confirm == null
                      ? null
                      : Semantics(
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _tap(context, confirmTap?.call(), options.verifyConfirm),
                            child: options.confirm!,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (options.bottom != null) column.add(options.bottom!);
    Widget content = child;
    if (options.contentPadding != null) {
      content = Padding(padding: options.contentPadding!, child: content);
    }
    if (options.background != null) {
      content = Stack(
        children: [
          Positioned(left: 0, bottom: 0, right: 0, top: 0, child: options.background!),
          content,
        ],
      );
    }
    column.add(content);
    if (options.bottomNavigationBar != null) {
      column.add(options.bottomNavigationBar!);
    }

    final Widget container = Container(
      decoration: options.decoration,
      // Container 不允许同时设置 color 和 decoration，decoration 优先
      color: options.decoration == null ? options.backgroundColor : null,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: column),
    );
    // 自定义 presenter（如 Cupertino 弹窗）可能没有 Material 文本环境，
    // 这里用 merge 显式补上主题字体，避免文字落到 Flutter 的 fallback 样式（等宽字体、黄色下划线），
    // 同时保留上层 DefaultTextStyle 的 textAlign 等设置
    return DefaultTextStyle.merge(style: Theme.of(context).textTheme.bodyMedium, child: container);
  }
}

/// 未配置头部时直接返回 [child]，否则包一层 [FlPickerSubject] 处理取消/确认
Widget _buildPicker<T>({
  required FlPickerOptions<T>? options,
  required Widget child,
  required FlPickerSubjectTapCallback<T> confirmTap,
}) => options == null ? child : FlPickerSubject<T>(options: options, confirmTap: confirmTap, child: child);

/// 多列选择器的横向布局。
/// [isScrollable] 为 true 时每列使用 [itemWidth]（为 null 时用 [kPickerDefaultItemWidth]）并可横向滚动；
/// 否则各列均分可用宽度。
class _FlPickerColumnLayout extends StatelessWidget {
  const _FlPickerColumnLayout({
    required this.columns,
    required this.width,
    required this.height,
    required this.isScrollable,
    this.itemWidth,
  });

  /// 每一列的组件
  final List<Widget> columns;

  /// 整体宽度
  final double width;

  /// 整体高度
  final double height;

  /// 是否横向滚动
  final bool isScrollable;

  /// 每一列的固定宽度
  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
    final bool fixedWidth = isScrollable || itemWidth != null;
    final List<Widget> children = [];
    for (final Widget column in columns) {
      if (fixedWidth) {
        children.add(
          SizedBox(width: isScrollable && itemWidth == null ? kPickerDefaultItemWidth : itemWidth, child: column),
        );
      } else {
        children.add(Expanded(child: column));
      }
    }
    Widget current = Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
    if (isScrollable) {
      current = SingleChildScrollView(scrollDirection: Axis.horizontal, child: current);
    }
    return SizedBox(width: width, height: height, child: current);
  }
}

class _FlPickerListWheel extends FlListWheel {
  _FlPickerListWheel({
    ValueChanged<int>? onChanged,
    required super.itemCount,
    required super.itemBuilder,
    required super.options,
    super.controller,
    super.onScrollEnd,
  }) : super.builder(onSelectedItemChanged: onChanged);
}

extension FlCustomPickerExtension<T> on FlCustomPicker<T> {
  /// 打开选择器弹窗，返回 [FlCustomPicker.confirmTap] 计算出的结果
  Future<T?> show({FlPickerPresenter? presenter}) => FlListWheel.showPicker<T>(this, presenter: presenter);
}

/// 自定义内容的选择器：只需提供内容和头部配置，
/// 结果由 [confirmTap]/[cancelTap] 决定。
class FlCustomPicker<T> extends FlPickerSubject<T> {
  const FlCustomPicker({super.key, required Widget content, required super.options, super.confirmTap, super.cancelTap})
    : super(child: content);
}
