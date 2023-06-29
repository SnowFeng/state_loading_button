import 'package:flutter/material.dart';
import 'package:state_loading_button/src/animated_button.dart';

class CircularProgress extends ButtonProgress {
  final Color? circularBackground; //进度条背景色
  final Gradient? circularBackgroundGradient; //进度条背景渐变色
  final double size; //进度条宽度
  final double? radius; //进度控件半径
  final double? ratio; //进度条半径占比（0到1）
  final BorderRadius? borderRadius;//不为空即设置背景为带圆角的矩形
  final bool reverse; //是否反转
  final double? startAngle; //进度开始角度（取弧度值，3点钟位置为0，反转后按照反方向计算）
  final StrokeCap strokeCap; //进度首尾形状

  const CircularProgress(
      {this.circularBackground,
      this.circularBackgroundGradient,
      this.size = 5,
      this.radius,
      this.ratio,
      this.borderRadius,
      this.reverse = false,
      this.startAngle,
      this.strokeCap = StrokeCap.round,
      super.progress,
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

  CircularProgress copyWith(
      {int? progress,
    ProgressType? progressType,
    Color? foreground,
    Color? background,
    Color? circularBackground,
    bool? isProgressOpacityAnim,
    TextStyle? textStyle,
    String? prefix,
    TextStyle? prefixStyle,
    String? suffix,
    TextStyle? suffixStyle,
    double? size,
    BorderRadius? borderRadius,
    double? radius,
    double? ratio,
    bool? reverse,
    StrokeCap? strokeCap,
    double? startAngle,
    BorderSide? borderSide,
    Gradient? circularBackgroundGradient,
    Gradient? foregroundGradient,
    Gradient? backgroundGradient,
    List<BoxShadow>? shadows}){
    return CircularProgress(
      progress: progress ?? this.progress,
      progressType: progressType ??this.progressType,
      foreground: foreground ??this.foreground,
      background: background ??this.background,
      circularBackground: circularBackground ?? this.circularBackground,
      isProgressOpacityAnim: isProgressOpacityAnim ?? this.isProgressOpacityAnim,
      textStyle: textStyle ??this.textStyle,
      prefix: prefix ??this.prefix,
      prefixStyle: prefixStyle??this.prefixStyle,
      suffix: suffix ??this.suffix,
      suffixStyle: suffixStyle??this.suffixStyle,
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      radius: radius ?? this.radius,
      ratio: ratio ?? this.ratio,
      reverse: reverse ?? this.reverse,
      strokeCap: strokeCap ?? this.strokeCap,
      startAngle: startAngle ?? this.startAngle,
      borderSide: borderSide?? this.borderSide,
      circularBackgroundGradient: circularBackgroundGradient ?? this.circularBackgroundGradient,
      foregroundGradient: foregroundGradient ??this.foregroundGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      shadows: shadows ??this.shadows,
    );
  }

  @override
  bool needChangeAnimation(ButtonProgress newProgress) {
    if(newProgress is CircularProgress){
      return newProgress.progressType!=this.progressType||newProgress.size!=this.size||newProgress.radius!=this.radius||newProgress.borderRadius!=this.borderRadius;
    }
    return true;
  }
}
