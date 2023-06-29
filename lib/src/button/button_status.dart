import 'package:flutter/material.dart';

///按钮状态
enum AnimatedButtonStatus {
  loading,
  button
}

class ButtonStatus {
  final double width;//自定义每个状态的宽高，下同
  final double height;
  final String state;//区分不同状态下的按钮
  final AnimatedButtonStatus status;//加载或按钮
  final String text;
  final TextStyle textStyle;
  final Color buttonColor;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final Gradient? gradient; //渐变色（会覆盖buttonColor）
  final bool isTapScale; //是否点击缩放
  final List<BoxShadow>? shadows; //阴影

  const ButtonStatus({
    this.width = 100,
    this.height = 36,
    this.state = '',
    this.status = AnimatedButtonStatus.button,
    this.text = 'Download',
    this.textStyle = const TextStyle(fontSize: 16.0, color: Colors.white),
    this.buttonColor = Colors.blue,
    this.borderRadius,
    this.borderSide,
    this.gradient,
    this.shadows,
    this.isTapScale=true,
  });

  ButtonStatus copyWith({
    double? width,
    double? height,
    String? state,
    AnimatedButtonStatus? status,
      String? text,
      TextStyle? textStyle,
      Color? buttonColor,
      BorderRadius? borderRadius,
      BorderSide? borderSide,
    Gradient? gradient,
        bool? isTapScale,
        bool? isTextAnim,
    List<BoxShadow>? shadows}) {
    return ButtonStatus(
      width: width ?? this.width,
      height: height ?? this.height,
      state: state ?? this.state,
      status: status ?? this.status,
      text: text ?? this.text,
      textStyle: textStyle ?? this.textStyle,
      buttonColor: buttonColor ?? this.buttonColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderSide: borderSide ?? this.borderSide,
      gradient: gradient ?? this.gradient,
      isTapScale: isTapScale ?? this.isTapScale,
      shadows: shadows ?? this.shadows,
    );
  }

  static const ButtonStatus loading=ButtonStatus(status: AnimatedButtonStatus.loading,text: '');

  ///是否需要改变动画参数
  bool needChangeAnimation(ButtonStatus newButton){
    return width!=newButton.width||height!=newButton.height||borderRadius!=newButton.borderRadius;
  }

}
