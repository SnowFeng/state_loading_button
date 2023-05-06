import 'dart:math';

import 'package:flutter/material.dart';

import 'button_progress.dart';
import 'button_status.dart';

class AnimatedButtonPainter extends CustomPainter {
  //无进度类型变化值
  double value;

  //进度值
  int progress;

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
    Paint paint = Paint();
    drawBackground(canvas, paint, size);
    if (buttonStatus.status == AnimatedButtonStatus.loading) {
      if (buttonProgress.isProgressCircular) {
        drawCircleProgress(canvas, paint, size);
      } else {
        drawLinearProgress(canvas, paint, size);
      }
    }
  }

  ///画圆形进度
  void drawCircleProgress(Canvas canvas, Paint paint, Size size) {
    double offset = size.height / 2;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = buttonProgress.size;
    if (buttonProgress.progressType ==
        AnimatedButtonProgressType.circularIndeterminate) {
      //不带进度
      paint.color = buttonProgress.foreground;
      double progressRadius = offset / 2; //进度条半径
      canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, offset), radius: progressRadius),
          2 * value * pi,
          1.5 * pi,
          false,
          paint);
      canvas.save();
      Path path = getPath(progressRadius, 1.5 * pi);
      canvas.translate(size.width / 2, offset);
      canvas.rotate(value * 2 * pi);
      canvas.drawPath(path, paint);
      canvas.restore();
    } else {
      //带进度
      Rect rect = Rect.fromCircle(
          center: Offset(size.width / 2, offset), radius: offset - offset / 3);
      if (progress > 0) {
        paint.color = buttonProgress.foreground;
        //让边界有弧形过渡
        paint.strokeCap = StrokeCap.round;
        //画进度条
        canvas.drawArc(rect, -0.5 * pi, progress / 100 * 2 * pi, false, paint);
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

  void drawStartOrEndArc(Canvas canvas, Paint paint, Size size, double diff,
      offset, bool isStart) {
    double angle = acos(diff / size.height);
    double startAngle2 = pi / 2 - angle;
    double sweepAngle2 = 2 * angle - pi;
    double startAngle1 = pi * 1.5 - angle;
    double sweepAngle1 = sweepAngle2;
    double leftStart = 0;
    if (isStart) {
      leftStart = 2 * (offset - offset * cos(sweepAngle2 / 2)) - size.height;
    } else {
      leftStart = size.width - 2 * (offset - offset * cos(sweepAngle2 / 2));
    }
    canvas.drawArc(
        Rect.fromLTWH(leftStart, 0.0, size.height, size.height),
        isStart ? startAngle2 : startAngle1,
        isStart ? sweepAngle2 : sweepAngle1,
        false,
        paint);
    canvas.drawArc(
        Rect.fromLTWH(isStart ? 0.0 : (size.width - size.height), 0.0,
            size.height, size.height),
        isStart ? startAngle1 : startAngle2,
        isStart ? sweepAngle1 : sweepAngle2,
        false,
        paint);
  }

  ///画线性进度
  void drawLinearProgress(Canvas canvas, Paint paint, Size size) {
    double offset = size.height / 2;
    paint.style = PaintingStyle.fill;
    //画进度条
    paint.color = buttonProgress.foreground;
    if (buttonProgress.progressType ==
        AnimatedButtonProgressType.linearIndeterminate) {
      //无进度显示
      double length = size.width / 3; //进度条长度
      double start = value * size.width;
      double end = start + length;
      if (end >= size.width) {
        //结束
        double diff = size.width - start;
        if (diff <= size.height) {
          drawStartOrEndArc(canvas, paint, size, diff, offset, false);
        } else {
          end = size.width;
          canvas.drawRRect(
              RRect.fromLTRBXY(start, 0.0, end, size.height, offset, offset),
              paint);
        }
        //开始
        diff = length - diff;
        if (diff <= size.height) {
          drawStartOrEndArc(canvas, paint, size, diff, offset, true);
        } else {
          RRect rRect =
              RRect.fromLTRBXY(0.0, 0.0, diff, size.height, offset, offset);
          canvas.drawRRect(rRect, paint);
        }
      } else {
        RRect rRect =
            RRect.fromLTRBXY(start, 0.0, end, size.height, offset, offset);
        canvas.drawRRect(rRect, paint);
      }
    } else {
      //有进度显示
      double right = progress / 100 * size.width;
      if (progress > 0) {
        if (right < offset * 2) {
          canvas.drawArc(Rect.fromLTWH(0.0, 0.0, size.height, size.height),
              pi * 3 / 2, pi * 2, false, paint);
        } else {
          canvas.drawRRect(
              RRect.fromLTRBXY(0.0, 0.0, right, size.height, offset, offset),
              paint);
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
  void drawBackground(Canvas canvas, Paint paint, Size size) {
    paint.color = buttonStatus.buttonColor;
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
    canvas.drawRRect(rRect, paint);
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
    if (buttonStatus.borderSide != null&&buttonStatus.borderSide!=BorderSide.none) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = buttonStatus.borderSide!.width;
      paint.color = buttonStatus.borderSide!.color;
      canvas.drawRRect(rRect, paint);
    }
  }

  ///画等腰三角形
  Path getPath(double radius, double radian) {
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
