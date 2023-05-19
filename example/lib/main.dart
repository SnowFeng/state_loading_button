import 'dart:async';

import 'package:state_loading_button/state_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final ButtonStateNotifier _statusNotifier=ButtonStateNotifier();

  final ButtonProgressNotifier _progressNotifier=ButtonProgressNotifier();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AnimatedButton'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedButton(
                buttonBuilder: (state){
                  return _normal.copyWith(text: '普通按钮');
                },
                onTap: (button){
                Fluttertoast.showToast(msg: '按钮点击');
                return;
              },
              ),
              AnimatedButton(
                  buttonBuilder: (state){
                    return _normal.copyWith(width: 200,height: 40,text: '自定义文字',textStyle: const TextStyle(fontSize: 12),buttonColor: Colors.orangeAccent);
                  },
                  onTap: (button){

                  },
              ),
              AnimatedButton(
                buttonBuilder: (state){
                  switch(state){
                    case 'loading':
                      return ButtonStatus.loading;
                    case 'normal':
                      return _normal;
                    case 'paused':
                      return _paused;
                    case 'complete':
                      return _complete;
                    case 'error':
                      return _error;
                  }
                  return _normal;
                },
                progressBuilder:(button,progress){
                  switch(button.state){
                    case 'normal':
                      return const ButtonProgress(
                          size: 13,
                          dimension: 200,
                          background: Colors.blue,
                          foreground: Colors.orangeAccent,
                          prefix: '前缀',
                          prefixStyle: TextStyle(color: Colors.blueGrey,fontSize: 8),
                          suffix: '后缀',
                          suffixStyle: TextStyle(color: Colors.blueAccent,fontSize: 8),
                          textStyle: TextStyle(color: Colors.black,fontSize: 10),
                          progressType: AnimatedButtonProgressType
                              .linearDeterminate);
                    case 'paused':
                      return const ButtonProgress(
                          prefix: '前缀很长\n',
                          prefixStyle: TextStyle(color: Colors.black,fontSize: 8),
                          suffix: '\n后缀很长',
                          suffixStyle: TextStyle(color: Colors.orangeAccent,fontSize: 8),
                          progressType: AnimatedButtonProgressType.circularDeterminate,size: 5,dimension: 40,borderSide: BorderSide(color: Colors.redAccent,width: 5));
                    case 'complete':
                     return const ButtonProgress(progressType: AnimatedButtonProgressType.linearIndeterminate,size: 10,dimension: 200);
                    case 'error':
                      return const ButtonProgress(progressType: AnimatedButtonProgressType.circularIndeterminate,size: 5,dimension: 30);
                    default:
                      return progress;
                  }
                },
                stateNotifier: _statusNotifier,
                buttonProgressNotifier: _progressNotifier,
                statusChangeDuration: const Duration(milliseconds: 1000),
                onTap: (button){
                  switch(button.state){
                    case 'normal':
                      _statusNotifier.changeState('loading');
                      int progress=0;
                      Timer.periodic(const Duration(milliseconds: 30), (timer) {
                        progress++;
                        _progressNotifier.changeProgress(progress:progress,foreground: Color.lerp(Colors.white, Colors.red, progress/100),background: Color.lerp(Colors.green, Colors.yellow, progress/100));
                        if(progress>100){
                          _statusNotifier.changeState('paused');
                          timer.cancel();
                        }
                      });
                      break;
                    case 'paused':
                      _statusNotifier.changeState('loading');
                      int progress=0;
                      Timer.periodic(const Duration(milliseconds: 30), (timer) {
                        _progressNotifier.changeProgress(progress:progress,foreground: Color.lerp(Colors.yellow, Colors.white, progress/100),background: Color.lerp(Colors.redAccent, Colors.blue, progress/100));
                        progress++;
                        if(progress>100){
                          _statusNotifier.changeState('error');
                          timer.cancel();
                        }
                      });
                      break;
                    case 'complete':
                      _statusNotifier.changeState('loading');
                      Future.delayed(const Duration(milliseconds: 3000),(){
                        _statusNotifier.changeState('normal');
                      });
                      break;
                    case 'error':
                      _statusNotifier.changeState('loading');
                      Future.delayed(const Duration(milliseconds: 3000),(){
                        _statusNotifier.changeState('complete');
                      });
                      break;
                  }
                },
              ),
            ],
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
    borderRadius: BorderRadius.all(Radius.circular(30)),
  );


  ///暂停
  static const ButtonStatus _paused = ButtonStatus(
      width: 200,
      state: 'paused',
      status: AnimatedButtonStatus.button,
      text: 'Paused',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.orangeAccent,
      borderRadius: BorderRadius.all(Radius.circular(12)));

  ///取消
  static const ButtonStatus _canceled = ButtonStatus(
      state: 'canceled',
      status: AnimatedButtonStatus.button,
      text: 'Canceled',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.grey,
      borderRadius: BorderRadius.all(Radius.circular(12)));

  ///完成
  static const ButtonStatus _complete = ButtonStatus(
      width: 80,
      height: 40,
      borderSide: BorderSide(color: Colors.black,width: 3),
      state: 'complete',
      status: AnimatedButtonStatus.button,
      text: 'Complete',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.greenAccent,
      borderRadius: BorderRadius.all(Radius.circular(12)));

  ///错误
  static const ButtonStatus _error = ButtonStatus(
      height: 50,
      borderSide: BorderSide(color: Colors.blue,width: 3),
      state: 'error',
      status: AnimatedButtonStatus.button,
      text: 'Error',
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      buttonColor: Colors.redAccent,
      borderRadius: BorderRadius.all(Radius.circular(12)));
}
