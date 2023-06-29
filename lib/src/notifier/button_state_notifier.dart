import 'package:flutter/material.dart';

class ButtonStateNotifier extends ChangeNotifier {
  String _state='';

  bool _isDisposed = false;

  ButtonStateNotifier() {
    _isDisposed = false;
  }

  void initState(String state){
    this._state=state;
  }

  String get value => _state;

  set value(String value) {
    if (_isDisposed) {
      return;
    }
    bool isNeedNotify=_state!=value;
    _state = value;
    if(isNeedNotify){
      notifyListeners();
    }
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
