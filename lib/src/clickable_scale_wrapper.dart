import 'package:flutter/material.dart';

class ClickableScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isTapScale;

  const ClickableScaleWrapper(
      {Key? key, required this.child, required this.onTap, this.isTapScale = true})
      : super(key: key);

  @override
  State<ClickableScaleWrapper> createState() => _ClickableScaleWrapperState();
}

class _ClickableScaleWrapperState extends State<ClickableScaleWrapper>
    with SingleTickerProviderStateMixin {
  final Duration _duration = const Duration(milliseconds: 150);

  late double _scale;
  late AnimationController _controller;
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
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    tapTime = DateTime.now();
    deferrable = false;
    _controller.reset();
    _controller.forward(from: 0);
  }

  void _onTapUp(TapUpDetails details) {
    reverse();
  }

  void _onTapCancel() {
    reverse();
  }

  void reverse() {
    if (tapTime == null) _controller.reverse();
    Duration diffDuration = DateTime.now().difference(tapTime!);
    if (diffDuration < _duration) {
      deferrable = true;
      Future.delayed(_duration - diffDuration, () {
        if (deferrable) {
          _controller.reverse();
        }
      });
    } else {
      _controller.reverse();
    }
  }

  void _onTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.isTapScale){
      return GestureDetector(
        onTap: _onTap,
        child: widget.child,
      );
    }
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTap: _onTap,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
