import 'dart:math';
import 'package:flutter/material.dart';
import 'package:state_loading_button/src/progress/circular_progress.dart';
import 'package:state_loading_button/src/progress/linear_progress.dart';
import 'package:state_loading_button/src/progress/polygon_progress.dart';
import 'package:state_loading_button/src/progress/rectangle_progress.dart';

import 'progress/button_progress.dart';
import 'button/button_status.dart';

class AnimatedButtonPainter extends CustomPainter {
  //无进度类型变化值
  double value;

  //进度值
  double progress;

  double statusValue;

  Paint buttonPaint = Paint();

  Paint progressPaint = Paint();

  //进度文字
  TextPainter textPainter = TextPainter()
    ..textAlign = TextAlign.center
    ..textDirection = TextDirection.ltr;

  final ButtonStatus buttonStatus;

  final ButtonProgress buttonProgress;

  AnimatedButtonPainter({
    required this.buttonStatus,
    required this.buttonProgress,
    this.progress = 0.0,
    this.value = 0.0,
    this.statusValue = 1.0,
  }) {
    progress = progress > 100 ? 100 : progress;
    value = value > 1 ? 1 : value;
    statusValue = statusValue > 1 ? 1 : statusValue;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    bool canDrawProgress = false;
    if (buttonProgress.isProgressOpacityAnim) {
      canDrawProgress = statusValue > 0;
    } else {
      canDrawProgress = buttonStatus.status == AnimatedButtonStatus.loading;
    }
    if (canDrawProgress) {
      if (buttonProgress is CircularProgress) {
        _drawCircleProgress(canvas, size, buttonProgress as CircularProgress);
      } else if (buttonProgress is RectangleProgress) {
        _drawRectangleProgress(
            canvas, size, buttonProgress as RectangleProgress);
      } else if (buttonProgress is PolygonProgress) {
        _drawPolygonProgress(canvas, size, buttonProgress as PolygonProgress);
      } else {
        _drawLinearProgress(canvas, size, buttonProgress as LinearProgress);
      }
    }
  }

  ///画圆形进度
  void _drawCircleProgress(
      Canvas canvas, Size size, CircularProgress buttonProgress) {
    double offset = size.height / 2;
    double radius = buttonProgress.progressType == ProgressType.indeterminate
        ? offset / 2
        : offset * 2 / 3; //默认半径：无进度为控件半径一半，有进度为2/3
    double? radio = buttonProgress.ratio;
    if (radio != null && radio > 0 && radio <= 1) {
      radius = offset * radio;
    }
    double startAngle = buttonProgress.startAngle ?? 0.0;
    bool isReverse = buttonProgress.reverse;
    progressPaint.style = PaintingStyle.stroke;
    progressPaint.strokeWidth = buttonProgress.size;
    if (buttonProgress.strokeCap == StrokeCap.square) {
      //不用这个，没啥用
      progressPaint.strokeCap = StrokeCap.butt;
    } else {
      progressPaint.strokeCap = buttonProgress.strokeCap;
    }
    double gapRound = 0.0;
    if (progressPaint.strokeCap != StrokeCap.butt) {
      gapRound = atan(progressPaint.strokeWidth / 2 / radius);
    }
    if (buttonProgress.progressType == ProgressType.indeterminate) {
      //不带进度
      progressPaint.color = buttonProgress.foreground.withOpacity(statusValue);
      double endAngle = buttonProgress.sweepAngle ?? 1.5 * pi; //进度结束弧度
      double rotate = value * 2 * pi + startAngle;
      Rect rect = Rect.fromCircle(center: Offset(0, 0), radius: radius);
      if (buttonProgress.foregroundGradient != null) {
        List<Color> colors = buttonProgress.foregroundGradient!.colors;
        List<double>? stops = buttonProgress.foregroundGradient!.stops;
        SweepGradient sweepGradient = SweepGradient(
            startAngle: isReverse ? 2 * pi - endAngle : 0.0,
            colors: isReverse ? colors.reversed.toList() : colors,
            endAngle: isReverse ? 2 * pi : endAngle,
            stops: isReverse ? stops?.reversed.toList() : stops,
            tileMode: TileMode.clamp,
            transform: GradientRotation(isReverse ? gapRound : -gapRound));
        progressPaint.shader = sweepGradient.createShader(rect);
      }
      canvas.save();
      Path path = _getPath(radius, endAngle, buttonProgress.size, isReverse);
      path.addArc(rect, isReverse ? 2 * pi - endAngle : 0.0, endAngle);
      canvas.translate(size.width / 2, offset);
      canvas.rotate(isReverse ? -rotate : rotate);
      canvas.drawPath(path, progressPaint);
      canvas.restore();
    } else {
      //带进度
      Rect rect = Rect.fromCircle(
          center: Offset(size.width / 2, offset), radius: radius);
      //画进度条背景
      if (buttonProgress.circularBackgroundGradient != null) {
        SweepGradient sweepGradient;
        if (buttonProgress.circularBackgroundGradient is SweepGradient) {
          sweepGradient =
              buttonProgress.circularBackgroundGradient! as SweepGradient;
        } else {
          sweepGradient = SweepGradient(
              colors: buttonProgress.circularBackgroundGradient!.colors);
        }
        progressPaint.shader = sweepGradient.createShader(rect);
        canvas.drawCircle(
            Offset(size.width / 2, offset), radius, progressPaint);
      } else if (buttonProgress.circularBackground != null) {
        progressPaint.color =
            buttonProgress.circularBackground!.withOpacity(statusValue);
        canvas.drawArc(rect, 0, 2 * pi, false, progressPaint);
      }
      double sweepAngle = progress / 100 * 2 * pi;
      double gradientStartAngle = isReverse ? 2 * pi - sweepAngle : startAngle;
      double gradientEndAngle = isReverse ? 2 * pi : sweepAngle;
      double progressStartAngle = isReverse
          ? -startAngle - sweepAngle - gapRound
          : startAngle + gapRound;
      SweepGradient? sweepGradient;
      if (buttonProgress.foregroundGradient != null &&
          gradientStartAngle < gradientEndAngle) {
        List<Color> colors = buttonProgress.foregroundGradient!.colors;
        List<double>? stops = buttonProgress.foregroundGradient!.stops;
        sweepGradient = SweepGradient(
            colors: isReverse ? colors.reversed.toList() : colors,
            startAngle: gradientStartAngle,
            endAngle: gradientEndAngle,
            stops: isReverse ? stops?.reversed.toList() : stops,
            tileMode: TileMode.clamp,
            transform: GradientRotation(isReverse ? -startAngle : startAngle));
      }
      progressPaint.shader = sweepGradient?.createShader(rect);
      if (progress > 0) {
        progressPaint.color =
            buttonProgress.foreground.withOpacity(statusValue);

        //画进度条
        canvas.drawArc(
            rect, progressStartAngle, sweepAngle, false, progressPaint);
      }
      List<TextSpan> spanChildren = [
        TextSpan(
            text:
                '${progress.toStringAsFixed(buttonProgress.progressReserve)}%',
            style: buttonProgress.textStyle.apply(
                color: buttonProgress.textStyle.color?.withOpacity(statusValue),
                fontSizeFactor: statusValue))
      ];
      if (buttonProgress.prefix != null) {
        spanChildren.insert(
            0,
            TextSpan(
                text: buttonProgress.prefix,
                style: buttonProgress.prefixStyle?.apply(
                    color: buttonProgress.prefixStyle?.color
                        ?.withOpacity(statusValue),
                    fontSizeFactor: statusValue)));
      }
      if (buttonProgress.suffix != null) {
        spanChildren.add(TextSpan(
            text: buttonProgress.suffix,
            style: buttonProgress.suffixStyle?.apply(
                color:
                    buttonProgress.suffixStyle?.color?.withOpacity(statusValue),
                fontSizeFactor: statusValue)));
      }
      textPainter.text = TextSpan(children: spanChildren);
      textPainter.layout();
      double textStarPositionX = (size.width - textPainter.size.width) / 2;
      double textStarPositionY = (size.height - textPainter.size.height) / 2;
      textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
    }
  }

  ///画线性进度
  void _drawLinearProgress(
      Canvas canvas, Size size, LinearProgress buttonProgress) {
    BorderRadius? borderRadius = buttonStatus.borderRadius;
    double offset = size.height / 2;
    bool isReverse = buttonProgress.reverse;
    progressPaint.style = PaintingStyle.fill;
    //画进度条
    progressPaint.color = buttonProgress.foreground.withOpacity(statusValue);
    if (buttonProgress.progressType == ProgressType.indeterminate) {
      //无进度显示
      double length =
          size.width * (buttonProgress.indicatorRatio ?? 1 / 3); //进度条长度
      double start;
      double end;
      if(isReverse){
        start = (1-value)*size.width;
        end = start - length;
        if(end < 0){
          canvas.clipRRect(_buildRRectFormBorderRadius(borderRadius, 0, 0,
              size.width, size.height, Radius.circular(offset)));
          //画最左侧进度
          RRect lRect = _buildRRectFormBorderRadius(borderRadius, 0, 0,
              start, size.height, Radius.circular(offset));
          _drawGradientRect(
              canvas, lRect, progressPaint, buttonProgress.foregroundGradient);
          //画最右侧进度
          RRect rRect = _buildRRectFormBorderRadius(
              borderRadius, size.width+end, 0, size.width, size.height, Radius.circular(offset));
          _drawGradientRect(
              canvas, rRect, progressPaint, buttonProgress.foregroundGradient);
        }else{
          RRect rRect = _buildRRectFormBorderRadius(
              borderRadius, end, 0, start, size.height, Radius.circular(offset));
          _drawGradientRect(
              canvas, rRect, progressPaint, buttonProgress.foregroundGradient);
        }
      }else{
        start = value * size.width;
        end = start + length;
        if (end >= size.width) {
          canvas.clipRRect(_buildRRectFormBorderRadius(borderRadius, 0, 0,
              size.width, size.height, Radius.circular(offset)));
          //画最左侧进度
          RRect lRect = _buildRRectFormBorderRadius(borderRadius, 0, 0,
              end - size.width, size.height, Radius.circular(offset));
          _drawGradientRect(
              canvas, lRect, progressPaint, buttonProgress.foregroundGradient);

          //画最右侧进度
          RRect rRect = _buildRRectFormBorderRadius(
              borderRadius, start, 0, end, size.height, Radius.circular(offset));
          _drawGradientRect(
              canvas, rRect, progressPaint, buttonProgress.foregroundGradient);
        } else {
          RRect rRect = _buildRRectFormBorderRadius(
              borderRadius, start, 0, end, size.height, Radius.circular(offset));
          _drawGradientRect(
              canvas, rRect, progressPaint, buttonProgress.foregroundGradient);
        }
      }
    } else {
      //有进度显示
      double progressLength  = progress / 100 * size.width;

      if (progress >= 0) {
        if (progressLength < offset * 2) {
          Rect rect = Rect.fromLTWH(isReverse ? size.width - size.height : 0.0, 0.0, size.height, size.height);
          progressPaint.shader =
              buttonProgress.foregroundGradient?.createShader(rect);
          canvas.drawArc(rect, pi * 3 / 2, pi * 2, false, progressPaint);
        } else {
          _drawGradientRect(
              canvas,
              _buildRRectFormBorderRadius(borderRadius, isReverse ? size.width - progressLength : 0, 0, isReverse ? size.width : progressLength,
                  size.height, Radius.circular(offset)),
              progressPaint,
              buttonProgress.foregroundGradient);
        }
      }
      List<TextSpan> spanChildren = [
        TextSpan(
            text:
                '${progress.toStringAsFixed(buttonProgress.progressReserve)}%',
            style: buttonProgress.textStyle.apply(
                color: buttonProgress.textStyle.color?.withOpacity(statusValue),
                fontSizeFactor: statusValue))
      ];
      if (buttonProgress.prefix != null) {
        spanChildren.insert(
            0,
            TextSpan(
                text: buttonProgress.prefix,
                style: buttonProgress.prefixStyle?.apply(
                    color: buttonProgress.prefixStyle?.color
                        ?.withOpacity(statusValue),
                    fontSizeFactor: statusValue)));
      }
      if (buttonProgress.suffix != null) {
        spanChildren.add(TextSpan(
            text: buttonProgress.suffix,
            style: buttonProgress.suffixStyle?.apply(
                color:
                    buttonProgress.suffixStyle?.color?.withOpacity(statusValue),
                fontSizeFactor: statusValue)));
      }
      textPainter.text = TextSpan(children: spanChildren);
      textPainter.layout();
      double textWidth = textPainter.width;
      double textStarPositionX = 0;
      double textStarPositionY = (size.height - textPainter.size.height) / 2;
      //文字是否跟随进度条移动
      if (buttonProgress.isTextFollowed) {

        //文字在进度条内
        if (buttonProgress.isTextInner) {
          double diff = progressLength - textWidth - buttonProgress.padding;
          if (diff > 5) {
            textStarPositionX = isReverse ? size.width - progressLength + buttonProgress.padding : diff;
          } else {
            textStarPositionX = isReverse ? size.width - textWidth - 5 : 5;
          }
        } else {
          //文字在进度条外
          textStarPositionX = isReverse ? size.width - progressLength - textWidth - buttonProgress.padding: progressLength+buttonProgress.padding;
          double diff;
          if(isReverse){
            diff = buttonProgress.padding;
          }else{
            diff = size.width - textWidth - buttonProgress.padding;
          }
          bool isOverflow = isReverse ? textStarPositionX < diff : textStarPositionX > diff;
          if (isOverflow) {
            textStarPositionX = diff;
          }
        }
      } else {
        textStarPositionX = isReverse ? 5: size.width - textWidth - 5;
      }
      textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
    }
  }

  ///构建带圆角的多边形路径
  List _buildRoundedCornerPath(List<Offset> points, double radius) {
    Path path = Path();

    double perimeter=0;

    for (int i = 0; i < points.length; i++) {
      Point<double> angularPoint = Point(points[i].dx, points[i].dy);
      Point<double> p1 = Point(points[i == 0 ? points.length - 1 : i - 1].dx,
          points[i == 0 ? points.length - 1 : i - 1].dy);
      Point<double> p2 = Point(points[i == points.length - 1 ? 0 : i + 1].dx,
          points[i == points.length - 1 ? 0 : i + 1].dy);

      //Vector 1
      double dx1 = angularPoint.x - p1.x;
      double dy1 = angularPoint.y - p1.y;

      //Vector 2
      double dx2 = angularPoint.x - p2.x;
      double dy2 = angularPoint.y - p2.y;

      //Angle between vector 1 and vector 2 divided by 2
      double angle = (atan2(dy1, dx1) - atan2(dy2, dx2)) / 2;

      // The length of segment between angular point and the
      // points of intersection with the circle of a given radius
      double tanV = tan(angle).abs();
      double segment = radius / tanV;

      //Check the segment
      double length1 = _getLength(dx1, dy1);
      double length2 = _getLength(dx2, dy2);

      double length = min(length1, length2);

      if (segment > length) {
        segment = length;
        radius = length * tanV;
      }

      // Points of intersection are calculated by the proportion between
      // the coordinates of the vector, length of vector and the length of the segment.
      var p1Cross =
          _getProportionPoint(angularPoint, segment, length1, dx1, dy1, false);
      var p2Cross =
          _getProportionPoint(angularPoint, segment, length2, dx2, dy2, false);

      // Calculation of the coordinates of the circle
      // center by the addition of angular vectors.
      double dx = angularPoint.x * 2 - p1Cross.x - p2Cross.x;
      double dy = angularPoint.y * 2 - p1Cross.y - p2Cross.y;

      double L = _getLength(dx, dy);
      double d = _getLength(segment, radius);

      var circlePoint = _getProportionPoint(angularPoint, d, L, dx, dy, false);

      //StartAngle and EndAngle of arc
      var startAngle =
          atan2(p1Cross.y - circlePoint.y, p1Cross.x - circlePoint.x);
      var endAngle =
          atan2(p2Cross.y - circlePoint.y, p2Cross.x - circlePoint.x);

      //Sweep angle
      var sweepAngle = endAngle - startAngle;

      //Some additional checks
      if (sweepAngle < 0) {
        sweepAngle = 2*pi+sweepAngle;
      }

      var p1Start = _getProportionPoint(p1, segment, length1, dx1, dy1, true);

      // var p2Start = _getProportionPoint(p2, segment, length2, dx2, dy2, true);

      perimeter += sqrt(pow(p1Cross.x-p1Start.x, 2)+pow(p1Cross.y-p1Start.y, 2));

      if (i == 0) {
        path.moveTo(p1Start.x, p1Start.y);
      }

      var left = circlePoint.x - radius;
      var top = circlePoint.y - radius;
      var diameter = 2 * radius;
      perimeter+=sweepAngle*radius;
      path.arcTo(Rect.fromLTWH(left, top, diameter, diameter), startAngle,
          sweepAngle,false);
    }

    return [path,perimeter];
  }

  double _getLength(double dx, double dy) {
    return sqrt(dx * dx + dy * dy);
  }

  Point<double> _getProportionPoint(Point<double> point, double segment,
      double length, double dx, double dy, bool isStart) {
    double factor = segment / length;
    if (isStart) {
      return Point<double>(point.x + dx * factor, point.y + dy * factor);
    }
    return Point<double>(point.x - dx * factor, point.y - dy * factor);
  }

  void _drawPolygonProgress(
      Canvas canvas, Size size, PolygonProgress buttonProgress) {
    bool reverse = buttonProgress.reverse;

    bool indeterminate =
        buttonProgress.progressType == ProgressType.indeterminate;

    double? cornerRadius = buttonProgress.borderRadius;

    //边数
    int count =buttonProgress.side;

    double indicatorWidth =
        (buttonProgress.indicatorRatio ?? 1 / 3) * size.width;

    String text = '';

    progressPaint.style = PaintingStyle.stroke;
    progressPaint.strokeWidth = buttonProgress.size;
    double radius = size.width / 2;
    //不带圆角的周长
    double perimeter = 2 * count * radius * sin(pi / count);

    Path path = Path();
    List<Offset> points = [];
    points.add(Offset(radius * cos(pi / count), radius * sin(pi / count)));
    //拿到多边形顶点集合
    for (int i = 2; i <= count * 2; i++) {
      if (i.isOdd) {
        double x = radius * cos(pi / count * i);
        double y = radius * sin(pi / count * i);
        points.add(Offset(x, y));
      }
    }
    if (cornerRadius != null && cornerRadius > 0) {
      List result=_buildRoundedCornerPath(points, cornerRadius);
      path = result[0];
      perimeter=result[1];
    } else {
      path.addPolygon(points, true);
    }
    //旋转平移处理
    Matrix4 m4 = Matrix4.translationValues(radius, size.height / 2, 0);
    if (count.isOdd) {
      //奇数边数才旋转
      m4.setRotationZ(pi / count + pi / 2 * 3);
    }
    path = path.transform(m4.storage);

    //进度长度
    double distance =
    indeterminate ? perimeter * value : perimeter * (progress / 100);

    //画阴影
    _drawShadowsPath(canvas, path, buttonProgress.shadows);

    //画边框
    if (buttonStatus.borderSide != null &&
        buttonStatus.borderSide != BorderSide.none) {
      buttonPaint.style = PaintingStyle.stroke;
      buttonPaint.strokeWidth = buttonStatus.borderSide!.width+buttonProgress.size;
      buttonPaint.color = buttonStatus.borderSide!.color;
      buttonPaint.shader = null;
      canvas.drawPath(path, buttonPaint);
    }

    buttonPaint.style = PaintingStyle.fill;
    buttonPaint.color = buttonStatus.buttonColor;
    buttonPaint.shader = buttonStatus.gradient?.createShader(path.getBounds());

    canvas.drawPath(path, buttonPaint); //画控件背景
    //画进度条背景
    if (buttonProgress.progressBackgroundGradient != null) {
      progressPaint.shader = buttonProgress.progressBackgroundGradient!
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, progressPaint);
    } else if (buttonProgress.progressBackground != null) {
      progressPaint.color =
          buttonProgress.progressBackground!.withOpacity(statusValue);
      canvas.drawPath(path, progressPaint);
    }
    if (buttonProgress.strokeCap == StrokeCap.square) {
      //不用这个，没啥用
      progressPaint.strokeCap = StrokeCap.butt;
    } else {
      progressPaint.strokeCap = buttonProgress.strokeCap;
    }

    progressPaint.color = buttonProgress.foreground.withOpacity(statusValue);

    if (reverse) {
      //反转
      path.computeMetrics().forEach((element) {
        double start = element.length - distance;
        double end = element.length;
        path = Path.from(element.extractPath(start, end));
      });
    } else {
      path.computeMetrics().forEach((element) {
        double start = 0;
        double end = distance;
        path = Path.from(element.extractPath(start, end));
      });
    }
    //无进度类型
    if (indeterminate) {
      text = buttonProgress.indeterminateText ?? '';
      path.computeMetrics().forEach((element) {
        //截取固定长度的path
        double start = reverse ? 0 : element.length - indicatorWidth;
        double end = reverse ? indicatorWidth : element.length;
        path = Path.from(element.extractPath(start, end));
      });
    } else {
      text = '${progress.toStringAsFixed(buttonProgress.progressReserve)}%';
    }
    progressPaint.shader =
        buttonProgress.foregroundGradient?.createShader(path.getBounds());
    canvas.drawPath(path, progressPaint);
    List<TextSpan> spanChildren = [
      TextSpan(
          text: text,
          style: buttonProgress.textStyle.apply(
              color: buttonProgress.textStyle.color?.withOpacity(statusValue),
              fontSizeFactor: statusValue))
    ];
    if (buttonProgress.prefix != null) {
      spanChildren.insert(
          0,
          TextSpan(
              text: buttonProgress.prefix,
              style: buttonProgress.prefixStyle?.apply(
                  color: buttonProgress.prefixStyle?.color
                      ?.withOpacity(statusValue),
                  fontSizeFactor: statusValue)));
    }
    if (buttonProgress.suffix != null) {
      spanChildren.add(TextSpan(
          text: buttonProgress.suffix,
          style: buttonProgress.suffixStyle?.apply(
              color:
                  buttonProgress.suffixStyle?.color?.withOpacity(statusValue),
              fontSizeFactor: statusValue)));
    }
    textPainter.text = TextSpan(children: spanChildren);
    textPainter.layout();
    double textStarPositionX = (size.width - textPainter.size.width) / 2;
    double textStarPositionY = (size.height - textPainter.size.height) / 2;
    textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
  }

  ///画矩形路径的进度条
  void _drawRectangleProgress(
      Canvas canvas, Size size, RectangleProgress buttonProgress) {
    BorderRadius? borderRadius =
        _buildRectBorderRadius(buttonStatus.borderRadius, size);
    bool reverse = buttonProgress.reverse;
    bool indeterminate =
        buttonProgress.progressType == ProgressType.indeterminate;

    RRect rRect = _buildRRectFormBorderRadius(
        borderRadius, 0, 0, size.width, size.height, Radius.zero);
    progressPaint.style = PaintingStyle.stroke;
    progressPaint.strokeWidth = buttonProgress.size;

    //画进度条背景
    if (buttonProgress.progressBackgroundGradient != null) {
      progressPaint.shader = buttonProgress.progressBackgroundGradient!
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRRect(rRect, progressPaint);
    } else if (buttonProgress.progressBackground != null) {
      progressPaint.color =
          buttonProgress.progressBackground!.withOpacity(statusValue);
      canvas.drawRRect(rRect, progressPaint);
    }
    if (buttonProgress.strokeCap == StrokeCap.square) {
      //不用这个，没啥用
      progressPaint.strokeCap = StrokeCap.butt;
    } else {
      progressPaint.strokeCap = buttonProgress.strokeCap;
    }
    progressPaint.color = buttonProgress.foreground.withOpacity(statusValue);
    Radius? topLeft = borderRadius?.topLeft;
    Radius? topRight = borderRadius?.topRight;
    Radius? bottomRight = borderRadius?.bottomRight;
    Radius? bottomLeft = borderRadius?.bottomLeft;

    double topLeftX = topLeft?.x ?? 0;
    double topRightX = topRight?.x ?? 0;
    double bottomRightX = bottomRight?.x ?? 0;
    double bottomLeftX = bottomLeft?.x ?? 0;

    double topLeftArc = 0.5 * pi * topLeftX;
    double topRightArc = 0.5 * pi * topRightX;
    double bottomRightArc = 0.5 * pi * bottomRightX;
    double bottomLeftArc = 0.5 * pi * bottomLeftX;

    //周长
    double perimeter = size.width * 2 +
        size.height * 2 -
        2 * topLeftX -
        2 * topRightX -
        2 * bottomRightX -
        2 * bottomLeftX +
        topLeftArc +
        topRightArc +
        bottomRightArc +
        bottomLeftArc;

    double indicatorWidth =
        (buttonProgress.indicatorRatio ?? 1 / 3) * size.width;

    String text = '';
    //进度路径
    Path path = Path();
    double distance;
    if (indeterminate) {
      distance = value * perimeter;
    } else {
      distance = progress / 100 * perimeter;
    }
    double topLength = size.width - topLeftX - topRightX;
    double topEnd = topLength + topRightArc;
    double rightLength = size.height - topRightX - bottomRightX;
    double rightEnd = topEnd + rightLength + bottomRightArc;
    double bottomLength = size.width - bottomLeftX - bottomRightX;
    double bottomEnd = rightEnd + bottomLength + bottomLeftArc;
    double leftLength = size.height - topLeftX - bottomLeftX;

    if (indeterminate) {
      //无进度类型首尾衔接
      if (distance < indicatorWidth) {
        if (indicatorWidth - topLeftArc > distance) {
          double relative = indicatorWidth - topLeftArc - distance;
          if (relative > leftLength) {
            double relativeLeft = relative - leftLength;
            if (bottomLeft != null) {
              double radio = relativeLeft / bottomLeftArc;
              if (relativeLeft > bottomLeftArc) {
                path.moveTo(
                    relativeLeft - bottomLeftArc + bottomLeftX, size.height);
                path.relativeLineTo(bottomLeftArc - relativeLeft, 0);
              } else {
                path.moveTo(bottomLeftX - bottomLeftX * sin(radio),
                    size.height - bottomLeftX * cos(radio));
              }
              path.arcTo(
                  _buildRectangleRadiusRect(bottomLeft, 2, size),
                  pi - 0.5 * pi * (radio > 1 ? 1 : radio),
                  0.5 * pi * (radio > 1 ? 1 : radio),
                  false);
            } else {
              path.moveTo(relativeLeft, size.height);
              path.relativeLineTo(-relativeLeft, 0);
            }
          } else {
            path.moveTo(0, relative + topLeftX);
            path.relativeLineTo(0, -relative);
          }
        }
        if (topLeft != null) {
          double radio = (indicatorWidth - distance) / topLeftArc;
          path.arcTo(
              _buildRectangleRadiusRect(topLeft, 3, size),
              1.5 * pi - 0.5 * pi * (radio > 1 ? 1 : radio),
              0.5 * pi * (radio > 1 ? 1 : radio),
              false);
        }
      } else {
        path.moveTo(topLeftX, 0);
      }
      double length = distance > topLength ? topLength : distance;
      path.relativeLineTo(length, 0);
    } else {
      //top
      path.moveTo(topLeftX, 0);
      double length = distance > topLength ? topLength : distance;
      path.relativeLineTo(length, 0);
    }
    if (distance > topLength) {
      //right
      if (topRight != null) {
        double radio = (distance - topLength) / topRightArc;
        path.arcTo(_buildRectangleRadiusRect(topRight, 0, size), -0.5 * pi,
            0.5 * pi * (radio > 1 ? 1 : radio), false);
      }
      if (distance > topEnd) {
        double relative = distance - topEnd;
        double length = relative > rightLength ? rightLength : relative;
        path.relativeLineTo(0, length);
      }
    }
    if (distance > topEnd + rightLength) {
      //bottom
      if (bottomRight != null) {
        double radio = (distance - topEnd - rightLength) / bottomRightArc;
        path.arcTo(_buildRectangleRadiusRect(bottomRight, 1, size), 0,
            0.5 * pi * (radio > 1 ? 1 : radio), false);
      }
      if (distance > rightEnd) {
        double relative = distance - rightEnd;
        double length = relative > bottomLength ? bottomLength : relative;
        path.relativeLineTo(-length, 0);
      }
    }
    if (distance > rightEnd + bottomLength) {
      //left
      if (bottomLeft != null) {
        double radio = (distance - rightEnd - bottomLength) / bottomLeftArc;
        path.arcTo(_buildRectangleRadiusRect(bottomLeft, 2, size), 0.5 * pi,
            0.5 * pi * (radio > 1 ? 1 : radio), false);
      }
      if (distance > bottomEnd) {
        double relative = distance - bottomEnd;
        double length = relative > leftLength ? leftLength : relative;
        path.relativeLineTo(0, -length);
      }
    }
    if (distance > bottomEnd + leftLength) {
      if (topLeft != null) {
        double radio = (distance - bottomEnd - leftLength) / topLeftArc;
        path.arcTo(_buildRectangleRadiusRect(topLeft, 3, size), pi,
            0.5 * pi * (radio > 1 ? 1 : radio), false);
      }
    }

    if (reverse) {
      Path newPath = Path();
      path.computeMetrics().forEach((element) {
        newPath.addPath(
            element.extractPath(0, element.length), Offset(size.width, 0),
            matrix4: Matrix4.rotationY(pi).storage); //借助变换实现反转
      });
      path = newPath;
    }
    //无进度类型
    if (indeterminate) {
      text = buttonProgress.indeterminateText ?? '';
      path.computeMetrics().forEach((element) {
        //截取固定长度的path
        double start = element.length - indicatorWidth;
        double end = element.length;
        path = Path.from(element.extractPath(start, end));
      });
    } else {
      text = '${progress.toStringAsFixed(buttonProgress.progressReserve)}%';
    }
    progressPaint.shader =
        buttonProgress.foregroundGradient?.createShader(path.getBounds());
    canvas.drawPath(path, progressPaint);
    List<TextSpan> spanChildren = [
      TextSpan(
          text: text,
          style: buttonProgress.textStyle.apply(
              color: buttonProgress.textStyle.color?.withOpacity(statusValue),
              fontSizeFactor: statusValue))
    ];
    if (buttonProgress.prefix != null) {
      spanChildren.insert(
          0,
          TextSpan(
              text: buttonProgress.prefix,
              style: buttonProgress.prefixStyle?.apply(
                  color: buttonProgress.prefixStyle?.color
                      ?.withOpacity(statusValue),
                  fontSizeFactor: statusValue)));
    }
    if (buttonProgress.suffix != null) {
      spanChildren.add(TextSpan(
          text: buttonProgress.suffix,
          style: buttonProgress.suffixStyle?.apply(
              color:
                  buttonProgress.suffixStyle?.color?.withOpacity(statusValue),
              fontSizeFactor: statusValue)));
    }
    textPainter.text = TextSpan(children: spanChildren);
    textPainter.layout();
    double textStarPositionX = (size.width - textPainter.size.width) / 2;
    double textStarPositionY = (size.height - textPainter.size.height) / 2;
    textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
  }

  BorderRadius? _buildRectBorderRadius(BorderRadius? borderRadius, Size size) {
    Radius? topLeft = borderRadius?.topLeft;
    Radius? topRight = borderRadius?.topRight;
    Radius? bottomRight = borderRadius?.bottomRight;
    Radius? bottomLeft = borderRadius?.bottomLeft;
    return borderRadius?.copyWith(
        topLeft: _buildMaxRadius(topLeft, size),
        topRight: _buildMaxRadius(topRight, size),
        bottomLeft: _buildMaxRadius(bottomLeft, size),
        bottomRight: _buildMaxRadius(bottomRight, size));
  }

  Radius? _buildMaxRadius(Radius? radius, Size size) {
    if (radius != null) {
      double radiusX = radius.x > size.height / 2 ? size.height / 2 : radius.x;
      radius = Radius.circular(radiusX);
    }
    return radius;
  }

  Rect _buildRectangleRadiusRect(Radius? radius, int type, Size size) {
    //topRight:0 bottomRight:1 bottomLeft:2 topLeft:3
    if (radius == null) {
      return Rect.zero;
    }
    double left = 0;
    double top = 0;
    final double x = radius.x * 2;
    switch (type) {
      case 0:
        left = size.width - x;
        break;
      case 1:
        left = size.width - x;
        top = size.height - x;
        break;
      case 2:
        top = size.height - x;
        break;
      case 3:
        top = 0;
        left = 0;
        break;
    }
    return Rect.fromLTWH(left, top, x, x);
  }

  ///画渐变色
  void _drawGradientRect(
      Canvas canvas, RRect rRect, Paint paint, Gradient? gradient) {
    paint.shader = gradient?.createShader(rRect.outerRect);
    canvas.drawRRect(rRect, paint);
  }

  ///画背景
  void _drawBackground(Canvas canvas, Size size) {
    if(buttonProgress is PolygonProgress&&buttonStatus.status==AnimatedButtonStatus.loading){///多边形类型不需要背景
      return;
    }
    //画圆角
    RRect rRect = _buildRRectFormBorderRadius(
        buttonStatus.borderRadius, 0, 0, size.width, size.height, Radius.zero);
    buttonPaint.style = PaintingStyle.fill;
    buttonPaint.color = buttonStatus.buttonColor;
    buttonPaint.shader = buttonStatus.gradient?.createShader(rRect.outerRect);
    canvas.drawRRect(rRect, buttonPaint);
    // _drawShadowsRRect(canvas, rRect, buttonStatus.shadows,buttonPaint);
    //画文字
    if (buttonStatus.text.isNotEmpty &&
        (buttonProgress.isProgressOpacityAnim ||
            buttonStatus.status != AnimatedButtonStatus.loading)) {
      TextStyle textStyle = buttonProgress.isProgressOpacityAnim
          ? buttonStatus.textStyle.apply(
              color: buttonStatus.textStyle.color?.withOpacity(1 - statusValue),
              fontSizeFactor: 1 - statusValue)
          : buttonStatus.textStyle;
      textPainter.text = TextSpan(text: buttonStatus.text, style: textStyle);
      textPainter.layout();
      double textStarPositionX = (size.width - textPainter.size.width) / 2;
      double textStarPositionY = (size.height - textPainter.size.height) / 2;
      textPainter.paint(canvas, Offset(textStarPositionX, textStarPositionY));
    }
    //画边框
    if (buttonStatus.borderSide != null &&
        buttonStatus.borderSide != BorderSide.none) {
      buttonPaint.style = PaintingStyle.stroke;
      buttonPaint.strokeWidth = buttonStatus.borderSide!.width;
      buttonPaint.color = buttonStatus.borderSide!.color;
      buttonPaint.shader = null;
      canvas.drawRRect(rRect, buttonPaint);
    }
  }

  ///构建圆角矩形
  RRect _buildRRectFormBorderRadius(BorderRadius? borderRadius, double left,
      double top, double right, double bottom, Radius defaultRadius) {
    Radius topLeft = borderRadius?.topLeft ?? defaultRadius;
    Radius topRight = borderRadius?.topRight ?? defaultRadius;
    Radius bottomRight = borderRadius?.bottomRight ?? defaultRadius;
    Radius bottomLeft = borderRadius?.bottomLeft ?? defaultRadius;
    RRect rRect = RRect.fromLTRBAndCorners(left, top, right, bottom,
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft);
    return rRect;
  }

  ///画等腰三角形
  Path _getPath(
      double radius, double radian, double progressSize, bool isReverse) {
    Path path = Path();
    double halfSide = progressSize * 0.3;
    double yPoint = 0;
    double xPoint = halfSide;
    path.moveTo(xPoint, yPoint + halfSide);

    path.lineTo(xPoint, yPoint - halfSide);

    double xVertex =
        xPoint + sqrt(pow(progressSize * 0.5, 2) - pow(halfSide, 2));
    path.lineTo(xVertex, yPoint);
    path.close();
    Matrix4 m4 = Matrix4.translationValues(radius * cos(radian),
        isReverse ? -radius * sin(radian) : radius * sin(radian), 0);
    m4.setRotationZ(isReverse ? -0.5 * pi - radian : 0.5 * pi + radian);
    path = path.transform(m4.storage);
    return path;
  }

  ///绘制带阴影的Path
  void _drawShadowsPath(
      Canvas canvas, Path path, List<BoxShadow>? shadows) {
    if (shadows != null) {
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
    // canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
