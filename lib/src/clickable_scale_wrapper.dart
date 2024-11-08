import 'package:flutter/material.dart';

class ClickableScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isTapScale;
  final BoxDecoration? decoration;
  final double tapDecorationScale;//点击时阴影扩散比例

  const ClickableScaleWrapper(
      {Key? key, required this.child, required this.onTap, this.isTapScale = true,this.decoration,this.tapDecorationScale=0.5})
      : super(key: key);

  @override
  State<ClickableScaleWrapper> createState() => _ClickableScaleWrapperState();
}

class _ClickableScaleWrapperState extends State<ClickableScaleWrapper>
    with TickerProviderStateMixin {
  final Duration _duration = const Duration(milliseconds: 150);

  late AnimationController _controller;
  late AnimationController _decorationController;
  late Animation<double> animation;
  DateTime? tapTime;
  bool deferrable = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    animation.addListener(() {
      setState(() {});
    });
    _decorationController = AnimationController(vsync: this,duration: _duration,upperBound: widget.tapDecorationScale);
  }
  @override
  void dispose() {
    _controller.dispose();
    _decorationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    tapTime = DateTime.now();
    deferrable = false;
    _controller.reset();
    _decorationController.reset();
    _controller.forward(from: 0);
    _decorationController.forward(from: 0);
  }

  void _onTapUp(TapUpDetails details) {
    reverse();
  }

  void _onTapCancel() {
    reverse();
  }

  void reverse() {
    if (tapTime == null){
      _controller.reverse();
      _decorationController.reverse();
    };
    Duration diffDuration = DateTime.now().difference(tapTime!);
    if (diffDuration < _duration) {
      deferrable = true;
      Future.delayed(_duration - diffDuration, () {
        if (deferrable) {
          _controller.reverse();
          _decorationController.reverse();
        }
      });
    } else {
      _controller.reverse();
      _decorationController.reverse();
    }
  }

  void _onTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDecorationWidget(_buildScaleWidget());
  }

  Widget _buildScaleWidget(){
    if(!widget.isTapScale){
      return GestureDetector(
        onTap: _onTap,
        child: widget.child,
      );
    }
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTap: _onTap,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: 1 + animation.value,
        child: widget.child,
      ),
    );
  }

  Widget _buildDecorationWidget(Widget child){
    if(widget.decoration!=null){
      return DecoratedBox(decoration: widget.decoration!.scale(1+_decorationController.value),child: child);
    }
    return child;
  }
}
