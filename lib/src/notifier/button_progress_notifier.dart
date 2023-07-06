import 'package:flutter/material.dart';
import 'package:state_loading_button/src/progress/circular_progress.dart';
import 'package:state_loading_button/src/progress/linear_progress.dart';
import 'package:state_loading_button/src/progress/rectangle_progress.dart';

import '../progress/button_progress.dart';

class ButtonProgressNotifier extends ChangeNotifier {

  ButtonProgress _buttonProgress = ButtonProgress.defaultProgress;

  ButtonProgressNotifier(){
    _isDisposed=false;
  }

  ButtonProgress get value => _buttonProgress;

  bool _isDisposed=false;

  set value(ButtonProgress value) {
    if(_isDisposed){
      return;
    }
    _buttonProgress = value;
    notifyListeners();
  }

  ///改变线性进度条属性
  void linear({
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
    BorderSide? borderSide,
    Gradient? foregroundGradient,
    Gradient? backgroundGradient,
    List<BoxShadow>? shadows
  }){
    if(_isDisposed){
      return;
    }
    LinearProgress? linearProgress;
    if(_buttonProgress is LinearProgress){
      linearProgress = _buttonProgress as LinearProgress;
    }
    _buttonProgress = LinearProgress(
      progress: progress??_buttonProgress.progress,
      progressReserve: progressReserve??_buttonProgress.progressReserve,
      progressType: progressType??_buttonProgress.progressType,
      foreground: foreground??_buttonProgress.foreground,
      background: background??_buttonProgress.background,
      isProgressOpacityAnim: isProgressOpacityAnim??_buttonProgress.isProgressOpacityAnim,
      textStyle: textStyle??_buttonProgress.textStyle,
      prefix: prefix??_buttonProgress.prefix,
      prefixStyle: prefixStyle??_buttonProgress.prefixStyle,
      suffix: suffix??_buttonProgress.suffix,
      suffixStyle: suffixStyle??_buttonProgress.suffixStyle,
      height: height??linearProgress?.height??10,
      borderRadius: borderRadius??linearProgress?.borderRadius,
      width: width??linearProgress?.width,
      padding: padding??linearProgress?.padding??5,
      indicatorRatio: indicatorRatio??linearProgress?.indicatorRatio??5,
      borderSide: borderSide??_buttonProgress.borderSide,
      foregroundGradient: foregroundGradient??_buttonProgress.foregroundGradient,
      backgroundGradient: backgroundGradient??_buttonProgress.backgroundGradient,
      shadows: shadows,
    );
    notifyListeners();
  }


  ///改变圆形进度条属性
  void circular({double? progress,
    int? progressReserve,
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
    bool? isArrow,
    bool? reverse,
    StrokeCap? strokeCap,
    double? startAngle,
    double? sweepAngle,
    BorderSide? borderSide,
    Gradient? circularBackgroundGradient,
    Gradient? foregroundGradient,
    Gradient? backgroundGradient,
    List<BoxShadow>? shadows}){
    if(_isDisposed){
      return;
    }
    CircularProgress? circularProgress;
    if(_buttonProgress is CircularProgress){
      circularProgress = _buttonProgress as CircularProgress;
    }
    _buttonProgress = CircularProgress(
      progress: progress??_buttonProgress.progress,
      progressReserve: progressReserve??_buttonProgress.progressReserve,
      progressType: progressType??_buttonProgress.progressType,
      foreground: foreground??_buttonProgress.foreground,
      background: background??_buttonProgress.background,
      circularBackground: circularBackground??circularProgress?.circularBackground,
      isProgressOpacityAnim: isProgressOpacityAnim??_buttonProgress.isProgressOpacityAnim,
      textStyle: textStyle??_buttonProgress.textStyle,
      prefix: prefix??_buttonProgress.prefix,
      prefixStyle: prefixStyle??_buttonProgress.prefixStyle,
      suffix: suffix??_buttonProgress.suffix,
      suffixStyle: suffixStyle??_buttonProgress.suffixStyle,
      size: size??circularProgress?.size??5,
      borderRadius: borderRadius??circularProgress?.borderRadius,
      radius: radius??circularProgress?.radius,
      ratio: ratio??circularProgress?.ratio,
      isArrow: isArrow??circularProgress?.isArrow,
      reverse: reverse??circularProgress?.reverse??false,
      strokeCap: strokeCap??circularProgress?.strokeCap??StrokeCap.round,
      startAngle: startAngle??circularProgress?.startAngle,
      sweepAngle: sweepAngle??circularProgress?.sweepAngle,
      borderSide: borderSide??_buttonProgress.borderSide,
      circularBackgroundGradient: circularBackgroundGradient??circularProgress?.circularBackgroundGradient,
      foregroundGradient: foregroundGradient??_buttonProgress.foregroundGradient,
      backgroundGradient: backgroundGradient??_buttonProgress.backgroundGradient,
      shadows: shadows,
    );
    notifyListeners();
  }

  ///改变矩形进度属性
  void rectangle({double? progress,
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
    BorderRadius? borderRadius,
    double? width,
    double? height,
    bool? reverse,
    StrokeCap? strokeCap,
    Color? progressBackground,
    Gradient? progressBackgroundGradient,
    double? startRatio,
    BorderSide? borderSide,
    Gradient? foregroundGradient,
    Gradient? backgroundGradient,
    List<BoxShadow>? shadows}){
    if(_isDisposed){
      return;
    }
    RectangleProgress? rectangleProgress;
    if(_buttonProgress is RectangleProgress){
      rectangleProgress = _buttonProgress as RectangleProgress;
    }
    _buttonProgress = RectangleProgress(
      progress: progress??_buttonProgress.progress,
      progressReserve: progressReserve??_buttonProgress.progressReserve,
      progressType: progressType??_buttonProgress.progressType,
      foreground: foreground??_buttonProgress.foreground,
      background: background??_buttonProgress.background,
      isProgressOpacityAnim: isProgressOpacityAnim??_buttonProgress.isProgressOpacityAnim,
      textStyle: textStyle??_buttonProgress.textStyle,
      prefix: prefix??_buttonProgress.prefix,
      prefixStyle: prefixStyle??_buttonProgress.prefixStyle,
      suffix: suffix??_buttonProgress.suffix,
      suffixStyle: suffixStyle??_buttonProgress.suffixStyle,
      indeterminateText: indeterminateText??rectangleProgress?.indeterminateText,
      indicatorRatio: indicatorRatio??rectangleProgress?.indicatorRatio,
      size: size??rectangleProgress?.size??5,
      width: width??rectangleProgress?.width,
      height: height??rectangleProgress?.height,
      borderRadius: borderRadius??rectangleProgress?.borderRadius,
      reverse: reverse??rectangleProgress?.reverse??false,
      strokeCap: strokeCap??rectangleProgress?.strokeCap??StrokeCap.round,
      borderSide: borderSide??_buttonProgress.borderSide,
      progressBackground: progressBackground??rectangleProgress?.progressBackground,
      progressBackgroundGradient: progressBackgroundGradient??rectangleProgress?.progressBackgroundGradient,
      foregroundGradient: foregroundGradient??_buttonProgress.foregroundGradient,
      backgroundGradient: backgroundGradient??_buttonProgress.backgroundGradient,
      shadows: shadows,
    );
    notifyListeners();
  }

  void addProgressChangeListener(
      void Function(ButtonProgress buttonProgress) listener) {
    if(_isDisposed){
      return;
    }
    addListener(() {
      listener.call(_buttonProgress);
    });
  }

  @override
  void dispose() {
    _isDisposed=true;
    super.dispose();
  }
}
