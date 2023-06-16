import 'package:flutter/material.dart';

import 'button_progress.dart';

class ButtonProgressNotifier extends ChangeNotifier {

  ButtonProgress _buttonProgress = const ButtonProgress();

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

  void changeProgress({
    int? progress,
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
    if(_isDisposed){
      return;
    }
    _buttonProgress = _buttonProgress.copyWith(
      progress: progress,
      progressType: progressType,
      foreground: foreground,
      background: background,
      circularBackground: circularBackground,
      isTextInner: isTextInner,
      isTextFollowed: isTextFollowed,
      isProgressOpacityAnim: isProgressOpacityAnim,
      textStyle: textStyle,
      prefix: prefix,
      prefixStyle: prefixStyle,
      suffix: suffix,
      suffixStyle: suffixStyle,
      size: size,
      borderRadius: borderRadius,
      dimension: dimension,
      padding: padding,
      borderSide: borderSide,
      circularBackgroundGradient: circularBackgroundGradient,
      foregroundGradient: foregroundGradient,
      backgroundGradient: backgroundGradient,
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
