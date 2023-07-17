import 'package:flutter/material.dart';
import 'package:state_loading_button/src/progress/circular_progress.dart';
import 'package:state_loading_button/src/progress/polygon_progress.dart';
import 'package:state_loading_button/src/progress/rectangle_progress.dart';

enum ProgressType {
  indeterminate, //无进度
  determinate, //带进度
}

abstract class ButtonProgress {
  final double progress;//进度值，最高100
  final int progressReserve;//进度值保留几位小数
  final ProgressType progressType;
  final Color foreground;
  final Color background;
  final bool isProgressOpacityAnim; //是否需要进度条透明变化动画
  final TextStyle textStyle;
  final String? prefix; //进度前缀
  final TextStyle? prefixStyle;
  final String? suffix; //进度后缀
  final TextStyle? suffixStyle;
  final BorderSide? borderSide;//背景边框
  final Gradient? foregroundGradient;
  final Gradient? backgroundGradient;
  final List<BoxShadow>? shadows;//背景阴影

  static ButtonProgress defaultProgress=const CircularProgress();

  const ButtonProgress({
    this.progress = 0.0,
    this.progressReserve = 1,
    this.progressType = ProgressType.indeterminate,
    this.foreground = Colors.orange,
    this.background = Colors.blueAccent,
    this.isProgressOpacityAnim = true,
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.prefix,
    this.prefixStyle,
    this.suffix,
    this.suffixStyle,
    this.borderSide,
    this.foregroundGradient,
    this.backgroundGradient,
    this.shadows
  });

  ///是否需要改变动画参数
  bool needChangeAnimation(ButtonProgress newProgress);

  ///是否是无进度类型
  bool get isIndeterminate => progressType == ProgressType.indeterminate;

  ///是否为圆形或矩形进度
  bool get isBoxProgress => this is CircularProgress||this is RectangleProgress || this is PolygonProgress;

}
