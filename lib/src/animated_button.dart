library fluwx;

export 'button_progress_notifier.dart';
export 'button_status.dart';
export 'button_progress.dart';
export 'button_state_notifier.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import 'animated_button_painter.dart';
import 'button_progress_notifier.dart';
import 'button_status.dart';
import 'button_progress.dart';

import 'button_state_notifier.dart';
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

  final ButtonStatus Function(String? type) buttonBuilder;

  final ButtonProgress Function(ButtonStatus button,ButtonProgress progress)? progressBuilder;

  final Duration? statusChangeDuration; //状态变化动画时长
  final Duration? loadingDuration; //无进度加载动画单次时长
  final AnimatedButtonTap? onTap;
  final ButtonStateNotifier? stateNotifier;
  final ButtonProgressNotifier? buttonProgressNotifier;

  const AnimatedButton({
    Key? key,
    required this.buttonBuilder,
    this.width,
    this.height,
    this.borderRadius,
    this.borderSide,
    this.progressBuilder,
    this.statusChangeDuration = const Duration(milliseconds: 500),
    this.loadingDuration = const Duration(milliseconds: 1000),
    this.onTap,
    this.stateNotifier,
    this.buttonProgressNotifier,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  ButtonStatus button = const ButtonStatus();

  ButtonProgress progress = const ButtonProgress();

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

  ///状态变化动画时不能点击
  bool canClick = true;

  @override
  void dispose() {
    _statusChangeController.dispose();
    _loadingController.dispose();
    widget.stateNotifier?.dispose();
    widget.buttonProgressNotifier?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    button = widget.buttonBuilder.call(null);
    progress = widget.progressBuilder?.call(const ButtonStatus(),const ButtonProgress())??const ButtonProgress();
    if (widget.stateNotifier != null) {
      widget.stateNotifier!.value = button.state;
    }
    if (widget.buttonProgressNotifier != null) {
      widget.buttonProgressNotifier!.value = progress;
    }
    widget.stateNotifier?.addStateChangeListener((state) {
      _changeButton(state);
    });

    widget.buttonProgressNotifier?.addProgressChangeListener((buttonProgress) {
      setState(() {
        if (progress.needChangeAnimation(buttonProgress)) {
          _initAnimation(button, buttonProgress);
        }
        progress = buttonProgress;
      });
    });

    _statusChangeController.addStatusListener((status) {
      if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
        canClick = false;
      } else {
        canClick = true;
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
      setState(() {});
      if (button.status != AnimatedButtonStatus.loading) {
        _loadingController.stop(canceled: false);
        _statusChangeController.reverse();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initAnimation(button, progress);
      setState(() {

      });
    });
  }

  ///状态改变
  void _changeButton(String state){
    ButtonStatus buttonStatus = widget.buttonBuilder.call(state);
    if(buttonStatus.status==AnimatedButtonStatus.loading){
      buttonStatus=button.copyWith(status: AnimatedButtonStatus.loading,state: buttonStatus.state,text: '');
    }
    if (button.needChangeAnimation(buttonStatus)) {
      _initAnimation(buttonStatus, progress);
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
  void _initAnimation(ButtonStatus button, ButtonProgress progress) {
    double startWidth = widget.width ?? button.width;
    double startHeight = widget.height ?? button.height;
    RenderObject? render=context.findRenderObject();
    if(render!=null){
      RenderBox renderBox=render as RenderBox;
      BoxConstraints constraints = renderBox.constraints;
      ///强约束下使用约束尺寸
      if(constraints.minWidth>startWidth){
        startWidth=constraints.minWidth;
      }
      if(constraints.minHeight>startHeight){
        startHeight=constraints.minHeight;
      }
    }
    double endWidth = startWidth;
    double endHeight = startHeight;
    double? dimension = progress.dimension;
    double corner = startHeight / 2;
    if (dimension != null) {
      if (progress.isProgressCircular) {
        //圆形进度条
        endWidth = dimension * 2;
        endHeight = dimension * 2;
        corner = dimension;
      } else {
        endWidth = dimension;
        endHeight = progress.size;
        corner = progress.size / 2;
      }
    } else {
      if (progress.isProgressCircular) {
        endWidth = startHeight;
        endHeight = startHeight;
        corner = startHeight / 2;
      } else {
        endWidth = startWidth;
        endHeight = progress.size;
        corner = progress.size / 2;
      }
    }
    CurvedAnimation curved = CurvedAnimation(
        parent: _statusChangeController, curve: const Interval(0.0, 1.0));
    _widthAnimation = Tween(begin: startWidth, end: endWidth).animate(curved);
    _heightAnimation =
        Tween(begin: startHeight, end: endHeight).animate(curved);
    if (button.borderRadius != null) {
      _cornerAnimation = BorderRadiusTween(
              begin: widget.borderRadius ?? button.borderRadius,
              end: BorderRadius.all(Radius.circular(corner)))
          .animate(curved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClickableScaleWrapper(
        isTapScale: button.isTapScale && widget.onTap != null,
        onTap: () async {

          if (!canClick) return;

          if (button.status == AnimatedButtonStatus.loading) return;//@TODO 加载中禁止点击?

          if(widget.progressBuilder!=null){
            if(widget.buttonProgressNotifier!=null){
              widget.buttonProgressNotifier!.value=widget.progressBuilder!.call(button,progress);
            }
          }
          widget.onTap?.call(button);
        },
        child: AnimatedBuilder(
            animation: _statusChangeController,
            builder: (BuildContext context, Widget? child) {
              return _buildButtonWidget();
            }));
  }

  Widget _buildButtonWidget() {
    double width= _widthAnimation?.value ?? (widget.width ?? button.width);
    double height= _heightAnimation?.value ?? (widget.height ?? button.height);
    return Center(//赋予宽约束
      child: CustomPaint(
        size: Size(width, height),
        painter: AnimatedButtonPainter(
            buttonStatus: button.copyWith(
                buttonColor: Color.lerp(button.buttonColor,
                    progress.background, _statusChangeController.value),
                borderRadius: _cornerAnimation?.value,
                borderSide: _buildBorderSide()),
            buttonProgress: progress,
            progress: progress.progress,
            value: _loadingController.value),
      ),
    );
  }

  BorderSide? _buildBorderSide(){
    BorderSide buttonBorderSide=widget.borderSide ?? button.borderSide??BorderSide.none;
    BorderSide progressBorderSide=progress.borderSide??BorderSide.none;
    return BorderSide.lerp(
        buttonBorderSide,
        progressBorderSide,
        _statusChangeController.value);
  }

}
