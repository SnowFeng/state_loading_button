# state_loading_button

一个简单的带进度动画的按钮，可自定义各种状态样式以及动态改变进度动画样式。

## 效果图
![](https://raw.githubusercontent.com/SnowFeng/state_loading_button/main/demo.gif)

## 构造
```dart
    AnimatedButton({
        Key? key,
        required this.buttonBuilder,        //构建按钮各个状态样式
        this.width,                         //所有状态统一宽高
        this.height,
        this.borderRadius,                  //所有状态统一圆角
        this.borderSide,                    //所有状态统一边框
        this.progressBuilder,               //当按钮点击时，根据状态构建进度样式
        this.statusChangeDuration = const Duration(milliseconds: 500), //按钮和进度转换动画时长
        this.loadingDuration = const Duration(milliseconds: 1000), //无进度值时，进度条一次动画的时长
        this.onTap, //点击事件
        this.stateNotifier, //控制状态切换
        this.buttonProgressNotifier, //控制进度值以及样式变化
      })
```
### 使用
```dart
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
                        _progressNotifier.changeProgress(progress:progress,foreground: Color.lerp(Colors.white, Colors.red, progress/100),background: Color.lerp(Colors.green, Colors.black, progress/100));
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
```




