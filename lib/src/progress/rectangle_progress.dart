import 'package:flutter/material.dart';
import 'package:state_loading_button/src/animated_button.dart';

///矩形路径进度条
class RectangleProgress extends ButtonProgress {
  final double? width;
  final double? height;
  final Color? progressBackground; //进度条背景色
  final Gradient? progressBackgroundGradient; //进度条背景渐变色
  final double size; //进度条宽度
  final BorderRadius? borderRadius;
  final bool reverse; //是否反转
  final StrokeCap strokeCap; //进度首尾形状
  final String? indeterminateText; //无进度显示文字
  final double? indicatorRatio; //无进度类型，进度长度比例(默认取宽度1/3)

  const RectangleProgress({
    this.width,
    this.height,
    this.progressBackground,
    this.progressBackgroundGradient,
    this.size = 5,
    this.borderRadius,
    this.reverse = false,
    this.strokeCap = StrokeCap.round,
    this.indeterminateText,
    this.indicatorRatio,
    super.progress,
    super.progressReserve,
    super.progressType,
    super.foreground,
    super.background,
    super.isProgressOpacityAnim,
    super.textStyle,
    super.prefix,
    super.prefixStyle,
    super.suffix,
    super.suffixStyle,
    super.borderSide,
    super.foregroundGradient,
    super.backgroundGradient,
    super.shadows,
  });

  RectangleProgress copyWith(
      {double? progress,
      int? progressReserve,
      ProgressType? progressType,
      Color? foreground,
      Color? background,
      bool? isProgressOpacityAnim,
      String? indeterminateText,
      double? indicatorRatio,
      TextStyle? textStyle,
      String? prefix,
      TextStyle? prefixStyle,
      String? suffix,
      TextStyle? suffixStyle,
      double? size,
      double? startRatio,
      BorderRadius? borderRadius,
      bool? reverse,
      StrokeCap? strokeCap,
      double? width,
      double? height,
      Color? progressBackground,
      Gradient? progressBackgroundGradient,
      Gradient? foregroundGradient,
      Gradient? backgroundGradient,
      BorderSide? borderSide,
      List<BoxShadow>? shadows}) {
    return RectangleProgress(
      progress: progress ?? this.progress,
      progressReserve: progressReserve ?? this.progressReserve,
      progressType: progressType ?? this.progressType,
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      isProgressOpacityAnim:
          isProgressOpacityAnim ?? this.isProgressOpacityAnim,
      indeterminateText: indeterminateText ?? this.indeterminateText,
      indicatorRatio: indicatorRatio ?? this.indicatorRatio,
      textStyle: textStyle ?? this.textStyle,
      prefix: prefix ?? this.prefix,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      suffix: suffix ?? this.suffix,
      suffixStyle: suffixStyle ?? this.suffixStyle,
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      width: width ?? this.width,
      height: height ?? this.height,
      reverse: reverse ?? this.reverse,
      strokeCap: strokeCap ?? this.strokeCap,
      borderSide: borderSide ?? this.borderSide,
      progressBackground: progressBackground ?? this.progressBackground,
      progressBackgroundGradient:
          progressBackgroundGradient ?? this.progressBackgroundGradient,
      foregroundGradient: foregroundGradient ?? this.foregroundGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  bool needChangeAnimation(ButtonProgress newProgress) {
    if (newProgress is RectangleProgress) {
      return newProgress.width != this.width ||
          newProgress.height != this.height ||
          newProgress.size != this.size ||
          newProgress.borderRadius != this.borderRadius;
    }
    return true;
  }
}
