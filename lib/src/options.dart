import 'package:flutter/cupertino.dart';

/// 滚轮的外观与滚动参数集合。
/// 可通过 [FlListWheel.wheelOptions] 全局设置，再在单个滚轮上传入自己的配置覆盖。
class FlWheelOptions {
  /// 完全自定义：Material 与 Cupertino 两套参数都可设置，
  /// 最终由 [isCupertino] 决定使用哪一套渲染
  const FlWheelOptions.custom({
    this.physics,
    this.diameterRatio = 2.0,
    this.perspective = 0.003,
    this.offAxisFraction = 0.0,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.overAndUnderCenterOpacity = 1.0,
    this.itemExtent = 30,
    this.squeeze = 1.0,
    this.renderChildrenOutsideViewport = false,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scrollBehavior,
    this.selectionOverlay,
    this.backgroundColor,
    this.isCupertino = false,
  });

  /// 默认 Material 风格：启用放大镜，无选中区域覆盖层
  const FlWheelOptions({
    this.physics,
    this.diameterRatio = 2.0,
    this.perspective = 0.003,
    this.offAxisFraction = 0.0,
    this.useMagnifier = true,
    this.magnification = 1.2,
    this.overAndUnderCenterOpacity = 1.0,
    this.itemExtent = 30,
    this.squeeze = 1.0,
    this.renderChildrenOutsideViewport = false,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scrollBehavior,
  }) : selectionOverlay = null,
       backgroundColor = null,
       isCupertino = false;

  /// iOS Cupertino 风格：默认带选中区域覆盖层
  const FlWheelOptions.cupertino({
    this.diameterRatio = 1.07,
    this.backgroundColor,
    this.offAxisFraction = 0.0,
    this.useMagnifier = true,
    this.magnification = 1.1,
    this.squeeze = 1.45,
    this.itemExtent = 30,
    this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
  }) : physics = null,
       overAndUnderCenterOpacity = 0.447,
       renderChildrenOutsideViewport = false,
       clipBehavior = Clip.hardEdge,
       perspective = 0.003,
       restorationId = null,
       scrollBehavior = null,
       isCupertino = true;

  /// 每个子项的高度
  final double itemExtent;

  /// 滚轮圆柱直径与视口高度的比例，越大越接近平面，越小弧度越明显
  final double diameterRatio;

  /// 选中项相对中心的水平偏移比例，用于制造左右倾斜效果
  final double offAxisFraction;

  /// 选中项的放大倍数，需配合 [useMagnifier] 生效
  final double magnification;

  /// 是否放大选中的子项
  final bool useMagnifier;

  /// 子项之间的挤压比例，值越小上下间距越大
  final double squeeze;

  /// 滚动物理效果；为 null 时使用 [FixedExtentScrollPhysics]，滚动结束自动对齐到整项。
  /// 传入其他 physics（如 [BouncingScrollPhysics]）可关闭吸附效果。
  final ScrollPhysics? physics;

  /// 3D 透视强度，取值范围约 0 ~ 0.01；仅非 Cupertino 模式生效
  final double perspective;

  /// 中心上下两侧子项的不透明度；仅非 Cupertino 模式生效
  final double overAndUnderCenterOpacity;

  /// 是否渲染视口外的子项；仅非 Cupertino 模式生效
  final bool renderChildrenOutsideViewport;

  /// 超出视口部分的裁剪方式；仅非 Cupertino 模式生效
  final Clip clipBehavior;

  /// 状态恢复标识；仅非 Cupertino 模式生效
  final String? restorationId;

  /// 滚动行为配置；仅非 Cupertino 模式生效
  final ScrollBehavior? scrollBehavior;

  /// 是否使用 iOS Cupertino 风格
  final bool isCupertino;

  /// 滚轮背景色；仅 Cupertino 模式生效
  final Color? backgroundColor;

  /// 选中区域的覆盖层；仅 Cupertino 模式生效
  final Widget? selectionOverlay;

  /// 复制并替换部分参数；传 null 表示保留当前值，
  /// 因此无法通过 copyWith 把可空字段重置回 null，需要时请直接构造新实例
  FlWheelOptions copyWith({
    double? itemExtent,
    double? diameterRatio,
    double? offAxisFraction,
    double? perspective,
    double? magnification,
    bool? useMagnifier,
    double? squeeze,
    ScrollPhysics? physics,
    Widget? selectionOverlay,
    Color? backgroundColor,
    bool? isCupertino,
    double? overAndUnderCenterOpacity,
    bool? renderChildrenOutsideViewport,
    Clip? clipBehavior,
    ScrollBehavior? scrollBehavior,
    String? restorationId,
  }) => FlWheelOptions.custom(
    isCupertino: isCupertino ?? this.isCupertino,
    itemExtent: itemExtent ?? this.itemExtent,
    diameterRatio: diameterRatio ?? this.diameterRatio,
    offAxisFraction: offAxisFraction ?? this.offAxisFraction,
    perspective: perspective ?? this.perspective,
    magnification: magnification ?? this.magnification,
    useMagnifier: useMagnifier ?? this.useMagnifier,
    squeeze: squeeze ?? this.squeeze,
    physics: physics ?? this.physics,
    selectionOverlay: selectionOverlay ?? this.selectionOverlay,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    clipBehavior: clipBehavior ?? this.clipBehavior,
    overAndUnderCenterOpacity: overAndUnderCenterOpacity ?? this.overAndUnderCenterOpacity,
    renderChildrenOutsideViewport: renderChildrenOutsideViewport ?? this.renderChildrenOutsideViewport,
    scrollBehavior: scrollBehavior ?? this.scrollBehavior,
    restorationId: restorationId ?? this.restorationId,
  );

  /// 以当前配置为默认值，用 [options] 中非 null 的参数覆盖。
  /// [isCupertino] 始终保留当前配置的值：bool 无法区分「未设置」与「显式 false」，
  /// 直接合并会把全局 Cupertino 意外切成 Material。
  /// 需要切换风格时请修改全局 [FlListWheel.wheelOptions] 或构造完整的新实例。
  FlWheelOptions merge([FlWheelOptions? options]) => copyWith(
    itemExtent: options?.itemExtent,
    diameterRatio: options?.diameterRatio,
    offAxisFraction: options?.offAxisFraction,
    perspective: options?.perspective,
    magnification: options?.magnification,
    useMagnifier: options?.useMagnifier,
    squeeze: options?.squeeze,
    physics: options?.physics,
    selectionOverlay: options?.selectionOverlay,
    backgroundColor: options?.backgroundColor,
    clipBehavior: options?.clipBehavior,
    overAndUnderCenterOpacity: options?.overAndUnderCenterOpacity,
    renderChildrenOutsideViewport: options?.renderChildrenOutsideViewport,
    scrollBehavior: options?.scrollBehavior,
    restorationId: options?.restorationId,
  );
}
