import 'package:flutter/material.dart';

class ButtonStateNotifier extends ChangeNotifier {
  String _state='';

  bool _isDisposed = false;

  ButtonStateNotifier() {
    _isDisposed = false;
  }

  String get value => _state;

  set value(String value) {
    if (_isDisposed) {
      return;
    }
    _state = value;
    notifyListeners();
  }

  ///改变按钮状态
  void changeState(String state) {
    if (_isDisposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  void addStateChangeListener(
      void Function(String state) listener) {
    if (_isDisposed) {
      return;
    }
    addListener(() {
      listener.call(_state);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
