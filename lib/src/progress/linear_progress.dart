import 'package:flutter/material.dart';
import 'package:state_loading_button/src/animated_button.dart';

///线性进度条
class LinearProgress extends ButtonProgress {
  final bool isTextInner; //文字是否在进度条内
  final bool isTextFollowed; //文字是否跟随进度条移动
  final double height; //进度条宽度
  final double? width; //进度条长度
  final BorderRadius? borderRadius; //进度条及背景圆角
  final double padding; //文字与进度条右边间距
  final double? indicatorRatio; //无进度类型，进度长度比例(默认取1/3)
  final bool reverse; //是否反向

  const LinearProgress({
    this.isTextInner = true,
    this.isTextFollowed = true,
    this.height = 10,
    this.width,
    this.borderRadius,
    this.padding = 5,
    this.indicatorRatio,
    this.reverse = false,
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

  LinearProgress copyWith({
    double? progress,
    int? progressReserve,
    ProgressType? progressType,
    Color? foreground,
    Color? background,
    bool? isTextInner,
    bool? isTextFollowed,
    bool? isProgressOpacityAnim,
    TextStyle? textStyle,
    String? prefix,
    TextStyle? prefixStyle,
    String? suffix,
    TextStyle? suffixStyle,
    double? height,
    BorderRadius? borderRadius,
    double? width,
    double? padding,
    double? indicatorRatio,
    bool? reverse,
    BorderSide? borderSide,
    Gradient? foregroundGradient,
    Gradient? backgroundGradient,
    List<BoxShadow>? shadows
  }){
    return LinearProgress(
      progress: progress ??this.progress,
      progressReserve: progressReserve ??this.progressReserve,
      progressType: progressType ??this.progressType,
      foreground: foreground ??this.foreground,
      background: background ??this.background,
      isTextInner: isTextInner??this.isTextInner,
      isTextFollowed: isTextFollowed??this.isTextFollowed,
      isProgressOpacityAnim: isProgressOpacityAnim ?? this.isProgressOpacityAnim,
      textStyle: textStyle ??this.textStyle,
      prefix: prefix ??this.prefix,
      prefixStyle: prefixStyle ??this.prefixStyle,
      suffix: suffix ??this.suffix,
      suffixStyle: suffixStyle ??this.suffixStyle,
      height: height ?? this.height,
      width: width ?? this.width,
      padding: padding ?? this.padding,
      indicatorRatio: indicatorRatio ?? this.indicatorRatio,
      reverse: reverse ?? this.reverse,
      borderRadius: borderRadius ?? this.borderRadius,
      borderSide: borderSide?? this.borderSide,
      foregroundGradient: foregroundGradient  ??this.foregroundGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      shadows: shadows ??this.shadows,
    );
  }

  @override
  bool needChangeAnimation(ButtonProgress newProgress) {
    if(newProgress is LinearProgress){
      return newProgress.progressType!=this.progressType||newProgress.height!=this.height||newProgress.width!=this.width||newProgress.borderRadius!=this.borderRadius;
    }
    return true;
  }
}
