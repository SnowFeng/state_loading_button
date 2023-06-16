import 'package:flutter/material.dart';

enum AnimatedButtonProgressType {
  circularIndeterminate, //圆形无进度
  circularDeterminate, //圆形带进度
  linearIndeterminate, //线性无进度
  linearDeterminate, //线性带进度
}

class ButtonProgress {
  final int progress;
  final AnimatedButtonProgressType progressType;
  final Color foreground;
  final Color background;
  final Color? circularBackground; //进度条背景（圆形进度）
  final bool isTextInner; //文字是否在进度条内（线性类型）
  final bool isTextFollowed; //文字是否跟随进度条移动（线性类型）
  final bool isProgressOpacityAnim; //是否需要进度条透明变化动画
  final TextStyle textStyle;
  final String? prefix; //进度前缀
  final TextStyle? prefixStyle;
  final String? suffix; //进度后缀
  final TextStyle? suffixStyle;
  final double size;//进度条宽度
  final double? dimension;//圆形进度条半径或线性进度条宽度
  final BorderRadius? borderRadius;//线性类型：进度条及背景圆角 ，圆形类型：不为空即设置背景为带圆角的矩形
  final double padding;//文字与进度条右边间距（线性类型）
  final BorderSide? borderSide;//边框
  final Gradient? circularBackgroundGradient;//圆形进度条背景渐变色，//注意圆形进度时必须使用SweepGradient
  final Gradient? foregroundGradient;//注意圆形进度时必须使用SweepGradient
  final Gradient? backgroundGradient;
  final List<BoxShadow>? shadows;//阴影

  const ButtonProgress({
    this.progress = 0,
    this.progressType = AnimatedButtonProgressType.circularIndeterminate,
    this.foreground = Colors.orange,
    this.background = Colors.blueAccent,
    this.circularBackground,
    this.isTextInner = true,
    this.isTextFollowed = true,
    this.isProgressOpacityAnim = true,
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.size=5,
    this.borderRadius,
    this.dimension,
    this.prefix,
    this.prefixStyle,
    this.suffix,
    this.suffixStyle,
    this.padding=5,
    this.borderSide,
    this.circularBackgroundGradient,
    this.foregroundGradient,
    this.backgroundGradient,
    this.shadows
  });

  ButtonProgress copyWith(
      { int? progress,
        AnimatedButtonProgressType? progressType,
        Color? foreground,
        Color? background,
        Color? circularBackground,
        bool? isTextInner,
        bool? isTextFollowed,
        bool? isProgressOpacityAnim,
        TextStyle? textStyle,
        String? prefix,
        TextStyle? prefixStyle,
        String? suffix,
        TextStyle? suffixStyle,
        double? size,
        BorderRadius? borderRadius,
        double? dimension,
        double? padding,
        BorderSide? borderSide,
        Gradient? circularBackgroundGradient,
        Gradient? foregroundGradient,
        Gradient? backgroundGradient,
        List<BoxShadow>? shadows
        }) {
    return ButtonProgress(
      progress: progress ?? this.progress,
      progressType: progressType ?? this.progressType,
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      circularBackground: circularBackground ?? this.circularBackground,
      isTextInner: isTextInner ?? this.isTextInner,
      isTextFollowed: isTextFollowed ?? this.isTextFollowed,
      isProgressOpacityAnim: isProgressOpacityAnim ?? this.isProgressOpacityAnim,
      textStyle: textStyle ?? this.textStyle,
      prefix: prefix ?? this.prefix,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      suffix: suffix ?? this.suffix,
      suffixStyle: suffixStyle ?? this.suffixStyle,
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      dimension: dimension ?? this.dimension,
      padding: padding ?? this.padding,
      borderSide: borderSide ?? this.borderSide,
      circularBackgroundGradient: circularBackgroundGradient ?? this.circularBackgroundGradient,
      foregroundGradient: foregroundGradient ?? this.foregroundGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      shadows: shadows ?? this.shadows,
    );
  }

  ///是否是圆形进度条
  bool get isProgressCircular => progressType ==
      AnimatedButtonProgressType.circularIndeterminate ||
      progressType ==
          AnimatedButtonProgressType.circularDeterminate;

  ///是否是无进度类型
  bool get isIndeterminate => progressType ==
      AnimatedButtonProgressType.circularIndeterminate ||
      progressType ==
          AnimatedButtonProgressType.linearIndeterminate;

  ///是否需要改变动画参数
  bool needChangeAnimation(ButtonProgress newProgress){
    return progressType!=newProgress.progressType||dimension!=newProgress.dimension||size!=newProgress.size;
  }
}
