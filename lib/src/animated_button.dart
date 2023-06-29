library fluwx;

export 'notifier/button_progress_notifier.dart';
export 'button/button_status.dart';
export 'progress/button_progress.dart';
export 'notifier/button_state_notifier.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_loading_button/src/progress/circular_progress.dart';
import 'package:state_loading_button/src/progress/linear_progress.dart';

import 'animated_button_painter.dart';
import 'notifier/button_progress_notifier.dart';
import 'button/button_status.dart';
import 'progress/button_progress.dart';

import 'notifier/button_state_notifier.dart';
import 'clickable_scale_wrapper.dart';

///按钮点击事件
typedef AnimatedButtonTap = FutureOr<void> Function(ButtonStatus button);

///这是一个带动画效果的按钮
///可设置点击效果、进度显示、状态显示
class AnimatedButton extends StatefulWidget {
  final double? width; //所有状态统一宽高

  final double? height;

  final BorderRadius? borderRadius; //所有状态统一圆角

  final BorderSide? borderSide; //所有状态统一边框

  final String? initialState; //初始状态

  final ButtonStatus Function(String? type) buttonBuilder;

  final ButtonProgress Function(ButtonStatus button, ButtonProgress progress)?
      progressBuilder;

  final Duration? statusChangeDuration; //状态变化动画时长
  final Duration? loadingDuration; //无进度加载动画单次时长
  final Curve statusCurve;
  final Curve loadingCurve;
  final AnimatedButtonTap? onTap;
  final ButtonStateNotifier? stateNotifier;
  final ButtonProgressNotifier? buttonProgressNotifier;

  const AnimatedButton(
      {Key? key,
      required this.buttonBuilder,
      this.width,
      this.height,
      this.borderRadius,
      this.borderSide,
      this.initialState,
      this.progressBuilder,
      this.statusChangeDuration = const Duration(milliseconds: 500),
      this.loadingDuration = const Duration(milliseconds: 1000),
      this.statusCurve = Curves.linear,
      this.loadingCurve = Curves.linear,
      this.onTap,
      this.stateNotifier,
      this.buttonProgressNotifier})
      : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  ButtonStatus button = const ButtonStatus();

  ButtonProgress progress = ButtonProgress.defaultProgress;

  //状态变化
  late final AnimationController _statusChangeController = AnimationController(
    duration: widget.statusChangeDuration,
    vsync: this,
  );

  //加载中
  late final AnimationController _loadingController =
      AnimationController(duration: widget.loadingDuration, vsync: this);

  Animation? _widthAnimation;
  Animation? _heightAnimation;
  Animation? _cornerAnimation;

  late final Animation _loadingAnimation;

  ///状态变化动画时不能点击
  bool canClick = true;

  @override
  void dispose() {
    _statusChangeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    button = widget.buttonBuilder.call(widget.initialState);
    widget.stateNotifier?.initState(button.state);
    progress = widget.progressBuilder?.call(button, ButtonProgress.defaultProgress) ??
        ButtonProgress.defaultProgress;
    if (widget.buttonProgressNotifier != null) {
      widget.buttonProgressNotifier!.value = progress;
    }
    _loadingAnimation = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: widget.loadingCurve)).animate(_loadingController);
    widget.stateNotifier?.addStateChangeListener((state) {
      if (mounted) {
        _changeButton(state);
      }
    });

    widget.buttonProgressNotifier?.addProgressChangeListener((buttonProgress) {
      if (mounted) {
        setState(() {
          bool needChange = progress.needChangeAnimation(buttonProgress);
          progress = buttonProgress;
          if (needChange) {
            _initAnimation(button);
          }
        });
      }
    });

    _statusChangeController.addStatusListener((status) {
      if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
        canClick = false;
      } else {//回到按钮状态
        canClick = true;
        if(_loadingController.isAnimating){
          _loadingController.reset();
        }
      }
      if (status == AnimationStatus.completed) {
        if (button.status == AnimatedButtonStatus.loading) {
          //无进度进度条需要加载动画
          if (progress.isIndeterminate && !_loadingController.isAnimating) {
            _loadingController.repeat();
          }
        } else {
          if (!_statusChangeController.isAnimating) {
            _statusChangeController.reverse();
          }
        }
      }
    });

    _loadingController.addListener(() {
      if (mounted) {
        setState(() {});
        if (button.status != AnimatedButtonStatus.loading) {
          _statusChangeController.reverse();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initAnimation(button);
      setState(() {});
    });
  }

  ///状态改变
  void _changeButton(String state) {
    ButtonStatus buttonStatus = widget.buttonBuilder.call(state);
    if (buttonStatus.status == AnimatedButtonStatus.loading) {
      buttonStatus = button.copyWith(
          status: AnimatedButtonStatus.loading,
          state: buttonStatus.state);
    }
    if (button.needChangeAnimation(buttonStatus)) {
      _initAnimation(buttonStatus);
    }
    setState(() {
      button = buttonStatus;
    });
    if (!_statusChangeController.isAnimating) {
      if (buttonStatus.status == AnimatedButtonStatus.loading) {
        _statusChangeController.forward();
      } else {
        _statusChangeController.reverse();
      }
    }
  }

  ///初始化动画
  void _initAnimation(ButtonStatus button) {
    double startWidth = widget.width ?? button.width;
    double startHeight = widget.height ?? button.height;
    RenderObject? render = context.findRenderObject();
    if (render != null) {
      RenderBox renderBox = render as RenderBox;
      BoxConstraints constraints = renderBox.constraints;

      ///强约束下使用约束尺寸
      if (constraints.minWidth > startWidth) {
        startWidth = constraints.minWidth;
      }
      if (constraints.minHeight > startHeight) {
        startHeight = constraints.minHeight;
      }
    }
    double endWidth = startWidth;
    double endHeight = startHeight;
    double corner = startHeight / 2;
    BorderRadius? progressRadius;
    if (progress.isProgressCircular) {
      CircularProgress circularProgress = progress as CircularProgress;
      if(circularProgress.radius == null){//未设置半径时：circular类型使用button高度的一半
        progress = circularProgress= circularProgress.copyWith(radius: button.height/2);
      }
      //圆形进度条
      endWidth = circularProgress.radius! * 2;
      endHeight = circularProgress.radius! * 2;
      corner = circularProgress.radius!;
      progressRadius = circularProgress.borderRadius??BorderRadius.all(Radius.circular(corner));
    } else {
      LinearProgress linearProgress = progress as LinearProgress;
      if(linearProgress.width == null){//未设置宽度时：linear类型使用button的宽度
        progress = linearProgress = linearProgress.copyWith(width: button.width);
      }
      endWidth = linearProgress.width!;
      endHeight = linearProgress.height;
      corner = linearProgress.height / 2;
      progressRadius = linearProgress.borderRadius??BorderRadius.all(Radius.circular(corner));
    }
    CurvedAnimation curved = CurvedAnimation(
        parent: _statusChangeController,
        curve: Interval(0.0, 1.0, curve: widget.statusCurve));
    _widthAnimation = Tween(begin: startWidth, end: endWidth).animate(curved);
    _heightAnimation =
        Tween(begin: startHeight, end: endHeight).animate(curved);
    _cornerAnimation = BorderRadiusTween(
            begin: widget.borderRadius ?? button.borderRadius,
            end: progressRadius)
        .animate(curved);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _statusChangeController,
        builder: (BuildContext context, Widget? child) {
          return _buildButtonWidget();
        });
  }

  Widget _buildButtonWidget() {
    double width = _widthAnimation?.value ?? (widget.width ?? button.width);
    double height = _heightAnimation?.value ?? (widget.height ?? button.height);
    return Center(
      //赋予宽约束
      child: ClickableScaleWrapper(
        decoration: BoxDecoration(
            borderRadius: _cornerAnimation?.value,
            boxShadow: _buildBoxShadows()),
        isTapScale: button.isTapScale &&
            widget.onTap != null &&
            button.status != AnimatedButtonStatus.loading,
        onTap: () async {
          if (!canClick) return;

          if (button.status == AnimatedButtonStatus.loading)
            return; //@TODO 加载中禁止点击?

          if (widget.progressBuilder != null) {
            if (widget.buttonProgressNotifier != null) {
              widget.buttonProgressNotifier!.value =
                  widget.progressBuilder!.call(button, progress);
            }
          }
          widget.onTap?.call(button);
        },
        child: CustomPaint(
          size: Size(width, height),
          painter: AnimatedButtonPainter(
              buttonStatus: button.copyWith(
                  buttonColor: _buildBackgroundColor(),
                  borderRadius: _cornerAnimation?.value,
                  borderSide: _buildBorderSide(),
                  gradient: _buildGradient(),
              ),
              buttonProgress: progress,
              progress: progress.progress,
              value: _loadingAnimation.value,
              statusValue: progress.isProgressOpacityAnim?_statusChangeController.value:1.0
          ),
        ),
      ),
    );
  }

  ///透明背景色处理
  Color? _buildBackgroundColor() {
    if (button.buttonColor.opacity == 0 && progress.background.opacity == 0) {
      return Colors.transparent;
    }
    if (button.buttonColor.opacity == 0) {
      return progress.background.withOpacity(1 - _statusChangeController.value);
    }
    if (progress.background.opacity == 0) {
      return button.buttonColor.withOpacity(1 - _statusChangeController.value);
    }
    return Color.lerp(
        button.buttonColor, progress.background, _statusChangeController.value);
  }

  List<BoxShadow>? _buildBoxShadows() {
    if (button.shadows == null && progress.shadows == null) {
      return null;
    }
    return BoxShadow.lerpList(
        button.shadows ?? [BoxShadow(color: Colors.transparent)],
        progress.shadows ?? [BoxShadow(color: Colors.transparent)],
        _statusChangeController.value);
  }


  Gradient? _buildGradient() {
    if (button.gradient == null && progress.backgroundGradient == null) {
      return null;
    }
    Gradient? buttonGradient = button.gradient;
    Gradient? progressGradient = progress.backgroundGradient;
    buttonGradient ??=
        LinearGradient(colors: [button.buttonColor, button.buttonColor]);
    progressGradient ??= LinearGradient(colors: [progress.background, progress.background]);
    return Gradient.lerp(
        buttonGradient, progressGradient, _statusChangeController.value);
  }

  BorderSide? _buildBorderSide() {
    BorderSide buttonBorderSide =
        widget.borderSide ?? button.borderSide ?? BorderSide.none;
    BorderSide progressBorderSide = progress.borderSide ?? BorderSide.none;
    return BorderSide.lerp(
        buttonBorderSide, progressBorderSide, _statusChangeController.value);
  }
}
