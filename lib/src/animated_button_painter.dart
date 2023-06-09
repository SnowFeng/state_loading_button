import 'dart:math';

import 'package:flutter/material.dart';

import 'button_progress.dart';
import 'button_status.dart';

class AnimatedButtonPainter extends CustomPainter {
  //无进度类型变化值
  double value;

  //进度值
  int progress;

  Paint buttonPaint= Paint();

  Paint progressPaint= Paint();

  final ButtonStatus buttonStatus;

  final ButtonProgress buttonProgress;

  AnimatedButtonPainter({
    required this.buttonStatus,
    required this.buttonProgress,
    this.progress = 0,
    this.value = 0.0,
  }) {
    progress = progress > 100 ? 100 : progress;
    value = value > 1 ? 1 : value;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    if (buttonStatus.status == AnimatedButtonStatus.loading) {
      if (buttonProgress.isProgressCircular) {
        _drawCircleProgress(canvas, size);
      } else {
        _drawLinearProgress(canvas, size);
      }
    }
  }

  ///画圆形进度
  void _drawCircleProgress(Canvas canvas, Size size) {
    double offset = size.height / 2;
    progressPaint.style = PaintingStyle.stroke;
    progressPaint.strokeWidth = buttonProgress.size;
    if (buttonProgress.progressType ==
        AnimatedButtonProgressType.circularIndeterminate) {
      //不带进度
      progressPaint.color = buttonProgress.foreground;
      double progressRadius = offset / 2; //进度条半径
      canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, offset), radius: progressRadius),
          2 * value * pi,
          1.5 * pi,
          false,
          progressPaint);
      canvas.save();
      Path path = _getPath(progressRadius, 1.5 * pi);
      canvas.translate(size.width / 2, offset);
      canvas.rotate(value * 2 * pi);
      canvas.drawPath(path, progressPaint);
      canvas.restore();
    } else {
      //带进度
      Rect rect = Rect.fromCircle(
          center: Offset(size.width / 2, offset), radius: offset - offset / 3);
      if (buttonProgress.circularBackground != null) {
        progressPaint.color = buttonProgress.circularBackground!;
        canvas.drawArc(rect, 0, 2 * pi, false, progressPaint); //画进度条背景
      }
      if (progress > 0) {
        progressPaint.color = buttonProgress.foreground;
        //让边界有弧形过渡
        progressPaint.strokeCap = StrokeCap.round;
        //画进度条
        canvas.drawArc(rect, -0.5 * pi, progress / 100 * 2 * pi, false, progressPaint);
      }
      //进度文字
      TextPainter textPainter = TextPainter();
      textPainter.textDirection = TextDirection.ltr;
      List<TextSpan> spanChildren = [
        TextSpan(text: '$progress%', style: buttonProgress.textStyle)
      ];
      if (buttonProgress.prefix != null) {
        spanChildren.insert(
            0,
            TextSpan(
                text: buttonProgress.prefix,
                style: buttonProgress.prefixStyle));
      }
      if (buttonProgress.suffix != null) {
        spanChildren.add(TextSpan(
            text: buttonProgress.suffix, style: buttonProgress.suffixStyle));
      }
      textPainter.text = TextSpan(children: spanChildren);
      textPainter.textAlign = TextAlign.center;
      textPainter.layout();
      double textStarPositionX = (size.width - textPainter.size.width) / 2;
      double textStarPositionY = (size.height - textPainter.size.height) / 2;
      textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
    }
  }

  ///画线性进度
  void _drawLinearProgress(Canvas canvas, Size size) {
    double offset = size.height / 2;
    progressPaint.style = PaintingStyle.fill;
    //画进度条
    progressPaint.color = buttonProgress.foreground;
    if (buttonProgress.progressType ==
        AnimatedButtonProgressType.linearIndeterminate) {
      //无进度显示
      double length = size.width / 3; //进度条长度
      double start = value * size.width;
      double end = start + length;
      if (end >= size.width) {
        canvas.clipRRect(RRect.fromLTRBXY(
            0.0, 0.0, size.width, size.height, offset, offset));
        canvas.drawRRect(
            RRect.fromLTRBXY(
                0.0, 0.0, end - size.width, size.height, offset, offset),
            progressPaint);
        canvas.drawRRect(
            RRect.fromLTRBXY(start, 0.0, end, size.height, offset, offset),
            progressPaint);
      } else {
        RRect rRect =
            RRect.fromLTRBXY(start, 0.0, end, size.height, offset, offset);
        canvas.drawRRect(rRect, progressPaint);
      }
    } else {
      //有进度显示
      double right = progress / 100 * size.width;
      if (progress > 0) {
        if (right < offset * 2) {
          canvas.drawArc(Rect.fromLTWH(0.0, 0.0, size.height, size.height),
              pi * 3 / 2, pi * 2, false, progressPaint);
        } else {
          canvas.drawRRect(
              RRect.fromLTRBXY(0.0, 0.0, right, size.height, offset, offset),
              progressPaint);
        }
      }
      //进度文字
      TextPainter textPainter = TextPainter();
      textPainter.textDirection = TextDirection.ltr;
      List<TextSpan> spanChildren = [
        TextSpan(text: '$progress%', style: buttonProgress.textStyle)
      ];
      if (buttonProgress.prefix != null) {
        spanChildren.insert(
            0,
            TextSpan(
                text: buttonProgress.prefix,
                style: buttonProgress.prefixStyle));
      }
      if (buttonProgress.suffix != null) {
        spanChildren.add(TextSpan(
            text: buttonProgress.suffix, style: buttonProgress.suffixStyle));
      }
      textPainter.text = TextSpan(children: spanChildren);
      textPainter.textAlign = TextAlign.center;
      textPainter.layout();
      double textWidth = textPainter.size.width;
      double textStarPositionX = 0;
      double textStarPositionY = (size.height - textPainter.size.height) / 2;
      if (buttonProgress.isTextFollowed) {
        //文字是否跟随进度条移动
        if (buttonProgress.isTextInner) {
          //文字在进度条内
          double diff = right - textWidth - buttonProgress.padding;
          if (diff > 5) {
            textStarPositionX = diff;
          } else {
            textStarPositionX = 5;
          }
        } else {
          //文字在进度条外
          textStarPositionX = right;
          if (textStarPositionX >
              size.width - textWidth - buttonProgress.padding) {
            textStarPositionX = size.width - textWidth - buttonProgress.padding;
          }
        }
      } else {
        textStarPositionX = size.width - textWidth - 5;
      }
      textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
    }
  }

  ///画背景
  void _drawBackground(Canvas canvas, Size size) {
    double offset = size.height / 2;
    RRect rRect =
        RRect.fromLTRBXY(0.0, 0.0, size.width, size.height, offset, offset);
    if (buttonStatus.borderRadius != null) {
      //画圆角
      Radius topLeft = buttonStatus.borderRadius!.topLeft;
      Radius topRight = buttonStatus.borderRadius!.topRight;
      Radius bottomRight = buttonStatus.borderRadius!.bottomRight;
      Radius bottomLeft = buttonStatus.borderRadius!.bottomLeft;
      rRect = RRect.fromLTRBAndCorners(0, 0, size.width, size.height,
          topLeft: topLeft,
          topRight: topRight,
          bottomRight: bottomRight,
          bottomLeft: bottomLeft);
    }
    buttonPaint.style = PaintingStyle.fill;
    buttonPaint.color = buttonStatus.buttonColor;
    _drawShadowsRRect(canvas, rRect, buttonStatus.shadows,buttonPaint);
    //画文字
    TextPainter textPainter = TextPainter();
    textPainter.textDirection = TextDirection.ltr;
    textPainter.text =
        TextSpan(text: buttonStatus.text, style: buttonStatus.textStyle);
    textPainter.layout();
    double textStarPositionX = (size.width - textPainter.size.width) / 2;
    double textStarPositionY = (size.height - textPainter.size.height) / 2;
    textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
    //画边框
    if (buttonStatus.borderSide != null &&
        buttonStatus.borderSide != BorderSide.none) {
      buttonPaint.style = PaintingStyle.stroke;
      buttonPaint.strokeWidth = buttonStatus.borderSide!.width;
      buttonPaint.color = buttonStatus.borderSide!.color;
      canvas.drawRRect(rRect, buttonPaint);
    }
  }

  ///画等腰三角形
  Path _getPath(double radius, double radian) {
    Path path = Path();
    double yPoint = sin(radian) * radius;
    double xPoint = cos(radian) * radius;
    double halfSide = buttonProgress.size * 0.3;

    path.moveTo(xPoint, yPoint + halfSide);

    path.lineTo(xPoint, yPoint - halfSide);

    double xVertex =
        xPoint + sqrt(pow(buttonProgress.size * 0.5, 2) - pow(halfSide, 2));
    path.lineTo(xVertex, yPoint);
    path.close();
    return path;
  }

  ///绘制带阴影的RRect
  void _drawShadowsRRect(Canvas canvas, RRect rRect, List<BoxShadow>? shadows,Paint paint) {
    if(shadows!=null){
      Path path=Path()..addRRect(rRect);
      for (final BoxShadow shadow in shadows) {
        final Paint shadowPainter = shadow.toPaint();
        if (shadow.spreadRadius == 0) {
          canvas.drawPath(path.shift(shadow.offset), shadowPainter);
        } else {
          Rect zone = path.getBounds();
          double xScale = (zone.width + shadow.spreadRadius) / zone.width;
          double yScale = (zone.height + shadow.spreadRadius) / zone.height;
          Matrix4 m4 = Matrix4.identity();
          m4.translate(zone.width / 2, zone.height / 2);
          m4.scale(xScale, yScale);
          m4.translate(-zone.width / 2, -zone.height / 2);
          canvas.drawPath(
              path.shift(shadow.offset).transform(m4.storage), shadowPainter);
        }
      }
    }
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
