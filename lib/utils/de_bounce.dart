
import 'dart:async';

import 'package:flutter/cupertino.dart';

class Debounce {
  final Duration duration;


  Debounce({
    this.duration = const Duration(milliseconds: 500),
  });

  Timer? _timer;

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(duration, action);
  }

  void stop(){
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}