import 'dart:async';
import 'dart:math';

import 'package:state_loading_button/state_loading_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ButtonStateNotifier _statusNotifier = ButtonStateNotifier();

  final ButtonProgressNotifier _progressNotifier = ButtonProgressNotifier();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('StateLoadingButton'),
        ),
        body: Center(
          child: AnimatedButton(
            buttonBuilder: (state) {
              switch (state) {
                case 'loading':
                  return ButtonStatus.loading;
                case 'normal':
                  return _normal;
                case 'paused':
                  return _paused;
                case 'cancel':
                  return _canceled;
                case 'complete':
                  return _complete;
                case 'error':
                  return _error;
                case 'polygon':
                  return _polygon;
              }
              return _normal;
            },
            progressBuilder: (button, progress) {
              switch (button.state) {
                case 'normal':
                  return LinearProgress(
                      height: 20,
                      width: 250,
                      background: Colors.blue,
                      foreground: Colors.orangeAccent,
                      foregroundGradient: const LinearGradient(colors: [Colors.orangeAccent,Colors.pink]),
                      backgroundGradient: const LinearGradient(colors: [Colors.blue,Colors.amber]),
                      shadows: [const BoxShadow(color: Colors.purpleAccent,offset: Offset(0, 4),blurRadius: 5)],
                      prefix: '前缀',
                      prefixStyle:
                          const TextStyle(color: Colors.blueGrey, fontSize: 10),
                      suffix: '后缀',
                      suffixStyle:
                          const TextStyle(color: Colors.blueAccent, fontSize: 10),
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 15),
                      borderRadius: BorderRadius.circular(5),
                      progressType:
                          ProgressType.determinate);
                case 'paused':
                  return CircularProgress(
                      textStyle: const TextStyle(color: Colors.redAccent, fontSize: 8),
                      prefix: '前缀\n',
                      prefixStyle:
                          const TextStyle(color: Colors.black, fontSize: 8),
                      suffix: '\n后缀',
                      suffixStyle: const TextStyle(
                          color: Colors.orangeAccent, fontSize: 8),
                      progressType:
                          ProgressType.determinate,
                      foregroundGradient: const SweepGradient(colors: [Colors.yellow, Colors.pink]),
                      circularBackground: Colors.blue,
                      size: 10,
                      radius: 50,
                      startAngle: -0.2*pi,
                      ratio: 0.8,
                      background: Theme.of(context).scaffoldBackgroundColor);
                case 'cancel':
                  return RectangleProgress(
                    width: 100,
                    height: 50,
                    progressType: ProgressType.determinate,
                    borderRadius: BorderRadius.circular(10),
                    indeterminateText: '无进度值',
                    textStyle: const TextStyle(color: Colors.white,fontSize: 12),
                    size: 7,
                    progressBackground: Colors.purpleAccent,
                  );
                case 'complete':
                  return const LinearProgress(
                      progressType:
                          ProgressType.indeterminate,
                      shadows: [BoxShadow(color: Colors.black,offset: Offset(0, 2),blurRadius: 5)],
                      foregroundGradient: LinearGradient(colors: [Colors.yellow,Colors.red]),
                      height: 10);
                case 'error':
                  return CircularProgress(
                      progressType:
                          ProgressType.indeterminate,
                      foregroundGradient: const SweepGradient(colors: [Colors.orange, Colors.purpleAccent]),
                      shadows: [const BoxShadow(color: Colors.yellow,offset: Offset(0, 2),blurRadius: 5)],
                      size: 8,
                      borderRadius: BorderRadius.circular(5),
                      radius: 40);
                case 'polygon':
                  return PolygonProgress(
                    width: 200,
                    progressType: ProgressType.indeterminate,
                    borderRadius: 15,
                    indeterminateText: '无进度值',
                    textStyle: const TextStyle(color: Colors.white,fontSize: 12),
                    size: 7,
                    side: 5,
                    shadows: [const BoxShadow(color: Colors.black,offset: Offset(0, 2),blurRadius: 5)],
                    borderSide: const BorderSide(width: 3,color: Colors.greenAccent),
                    progressBackground: Colors.purpleAccent,
                  );
                default:
                  return progress;
              }
            },
            stateNotifier: _statusNotifier,
            buttonProgressNotifier: _progressNotifier,
            loadingDuration: const Duration(milliseconds: 2000),
            onTap: (button) {
              switch (button.state) {
                case 'normal':
                  _statusNotifier.value='loading';
                  double progress = 0;
                  Timer.periodic(const Duration(milliseconds: 30), (timer) {
                    progress++;
                    _progressNotifier.linear(
                        progress: progress,
                        foreground: Color.lerp(
                            Colors.white, Colors.red, progress / 100),
                        background: Color.lerp(
                            Colors.green, Colors.yellow, progress / 100)
                    );
                    if (progress > 100) {
                      _statusNotifier.value='paused';
                      timer.cancel();
                    }
                  });
                  break;
                case 'paused':
                  _statusNotifier.value='loading';
                  double progress = 0;
                  Timer.periodic(const Duration(milliseconds: 30), (timer) {
                    _progressNotifier.circular(
                        progress: progress,
                        radius: 50.0+progress/100*20,
                        size: 10.0+progress/100*10,
                        textStyle: TextStyle.lerp(const TextStyle(color: Colors.black, fontSize: 8), const TextStyle(color: Colors.white, fontSize: 20), progress / 100),
                        foreground: Color.lerp(
                            Colors.yellow, Colors.white, progress / 100),
                        background: Color.lerp(
                            Colors.redAccent, Colors.blue, progress / 100),
                        circularBackground: Color.lerp(Colors.pink, Colors.purple, progress / 100),
                    );
                    progress++;
                    if (progress > 100) {
                      _statusNotifier.value='cancel';
                      timer.cancel();
                    }
                  });
                  break;
                case 'cancel':
                  _statusNotifier.value='loading';
                  double progress = 0;
                  Timer.periodic(const Duration(milliseconds: 30), (timer) {
                    progress+=0.1;
                    _progressNotifier.rectangle(
                        progress: progress
                    );
                    if (progress > 100) {
                      _statusNotifier.value='polygon';
                      timer.cancel();
                    }
                  });
                  break;
                case 'complete':
                  _statusNotifier.value='loading';
                  Future.delayed(const Duration(milliseconds: 4000), () {
                    _statusNotifier.value='normal';
                  });
                  break;
                case 'error':
                  _statusNotifier.value='loading';
                  Future.delayed(const Duration(milliseconds: 4000), () {
                    _statusNotifier.value='complete';
                  });
                  break;
                case 'polygon':
                  _statusNotifier.value='loading';
                  Future.delayed(const Duration(milliseconds: 4000), () {
                    _statusNotifier.value='error';
                  });
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  ///默认
  static const ButtonStatus _normal = ButtonStatus(
    state: 'normal',
    status: AnimatedButtonStatus.button,
    text: 'click loading',
    textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
    buttonColor: Colors.blue,
    gradient: LinearGradient(colors: [Colors.pink,Colors.purple]),
    borderRadius: BorderRadius.all(Radius.circular(18)),
    shadows: [BoxShadow(
        color: Colors.redAccent,
        offset: Offset(0, 2),
        blurRadius: 4
    )]
  );

  ///暂停
  static const ButtonStatus _paused = ButtonStatus(
      width: 160,
      state: 'paused',
      status: AnimatedButtonStatus.button,
      text: 'Paused',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.orangeAccent,
      gradient: LinearGradient(colors: [Colors.orangeAccent,Colors.greenAccent]),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      shadows: [BoxShadow(
          color: Colors.blue,
          offset: Offset(0, 2),
          blurRadius: 8
      )]
  );

  ///取消
  static const ButtonStatus _canceled = ButtonStatus(
      width: 200,
      state: 'cancel',
      status: AnimatedButtonStatus.button,
      text: 'Canceled',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.grey,
      shadows: [BoxShadow(color: Colors.black,offset: Offset(0, 2),blurRadius: 5)],
      borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  ///完成
  static const ButtonStatus _complete = ButtonStatus(
      width: 200,
      height: 40,
      isTapScale: false,
      state: 'complete',
      status: AnimatedButtonStatus.button,
      text: 'Complete',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.greenAccent,
      gradient: LinearGradient(colors: [Colors.greenAccent,Colors.blue]),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      shadows: [BoxShadow(
          color: Colors.blue,
          blurRadius: 8
      )]
  );

  ///错误
  static const ButtonStatus _error = ButtonStatus(
      width: 200,
      height: 50,
      borderSide: BorderSide(color: Colors.blue, width: 3),
      state: 'error',
      status: AnimatedButtonStatus.button,
      text: 'Error',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.redAccent,
      gradient: LinearGradient(colors: [Colors.redAccent,Colors.purpleAccent]),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      shadows: [BoxShadow(
      color: Colors.blue,
      blurRadius: 8
  )]
  );

  ///多边形
  static const ButtonStatus _polygon = ButtonStatus(
    width: 200,
    state: 'polygon',
    status: AnimatedButtonStatus.button,
    text: 'Polygon',
    textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
    buttonColor: Colors.indigoAccent,
    shadows: [BoxShadow(color: Colors.greenAccent,offset: Offset(0, 2),blurRadius: 5)],
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
}
