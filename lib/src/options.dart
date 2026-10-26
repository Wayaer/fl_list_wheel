import 'package:flutter/cupertino.dart';

class WheelOptions {
  const WheelOptions.custom(
      {this.physics,
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
      this.isCupertino = false});

  const WheelOptions({
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
  })  : selectionOverlay = null,
        backgroundColor = null,
        isCupertino = false;

  const WheelOptions.cupertino({
    this.diameterRatio = 1.07,
    this.backgroundColor,
    this.offAxisFraction = 0.0,
    this.useMagnifier = true,
    this.magnification = 1.1,
    this.squeeze = 1.45,
    this.itemExtent = 30,
    this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
  })  : physics = null,
        overAndUnderCenterOpacity = 0.447,
        renderChildrenOutsideViewport = false,
        clipBehavior = Clip.hardEdge,
        perspective = 0.003,
        restorationId = null,
        scrollBehavior = null,
        isCupertino = true;

  /// wheel子item高度
  final double itemExtent;

  /// 半径大小,越大则越平面,越小则间距越大
  final double diameterRatio;

  /// 选中item偏移
  final double offAxisFraction;

  /// 放大倍率
  final double magnification;

  /// 是否启用放大镜
  final bool useMagnifier;

  /// 上下间距默认为1.45 数越小 间距越大
  final double squeeze;

  /// ScrollPhysics
  final ScrollPhysics? physics;

  /// 表示车轮水平偏离中心的程度  范围[0,0.01]
  /// [isCupertino]=false生效
  final double perspective;

  /// [isCupertino]=false生效
  final double overAndUnderCenterOpacity;

  /// [isCupertino]=false生效
  final bool renderChildrenOutsideViewport;

  /// [isCupertino]=false生效
  final Clip clipBehavior;

  /// [isCupertino]=false生效
  final String? restorationId;

  /// [isCupertino]=false生效
  final ScrollBehavior? scrollBehavior;

  /// 是否使用ios 样式
  final bool isCupertino;

  /// [isCupertino]=true生效
  final Color? backgroundColor;

  /// [isCupertino]=true生效
  final Widget? selectionOverlay;

  WheelOptions copyWith(
          {double? itemExtent,
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
          String? restorationId}) =>
      WheelOptions.custom(
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
          overAndUnderCenterOpacity:
              overAndUnderCenterOpacity ?? this.overAndUnderCenterOpacity,
          renderChildrenOutsideViewport: renderChildrenOutsideViewport ??
              this.renderChildrenOutsideViewport,
          scrollBehavior: scrollBehavior ?? this.scrollBehavior,
          restorationId: restorationId ?? this.restorationId);

  WheelOptions merge([WheelOptions? options]) => copyWith(
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
      isCupertino: options?.isCupertino,
      clipBehavior: options?.clipBehavior,
      overAndUnderCenterOpacity: options?.overAndUnderCenterOpacity,
      renderChildrenOutsideViewport: options?.renderChildrenOutsideViewport,
      scrollBehavior: options?.scrollBehavior,
      restorationId: options?.restorationId);
}
