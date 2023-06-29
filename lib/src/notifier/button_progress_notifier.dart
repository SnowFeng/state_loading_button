import 'package:flutter/material.dart';
import 'package:state_loading_button/src/progress/circular_progress.dart';
import 'package:state_loading_button/src/progress/linear_progress.dart';

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
    int? progress,
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
      borderSide: borderSide??_buttonProgress.borderSide,
      foregroundGradient: foregroundGradient??_buttonProgress.foregroundGradient,
      backgroundGradient: backgroundGradient??_buttonProgress.backgroundGradient,
      shadows: shadows,
    );
    notifyListeners();
  }


  ///改变圆形进度条属性
  void circular({int? progress,
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
    if(_isDisposed){
      return;
    }
    CircularProgress? circularProgress;
    if(_buttonProgress is CircularProgress){
      circularProgress = _buttonProgress as CircularProgress;
    }
    _buttonProgress = CircularProgress(
      progress: progress??_buttonProgress.progress,
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
      reverse: reverse??circularProgress?.reverse??false,
      strokeCap: strokeCap??circularProgress?.strokeCap??StrokeCap.round,
      startAngle: startAngle??circularProgress?.startAngle,
      borderSide: borderSide??_buttonProgress.borderSide,
      circularBackgroundGradient: circularBackgroundGradient??circularProgress?.circularBackgroundGradient,
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
