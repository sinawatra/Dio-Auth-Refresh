import 'dart:async';

class RequestQueue {
  final _completer = <Completer<void>>[];

  Future<void> wait() {
    final completer = Completer<void>();
    _completer.add(completer);
    return completer.future;
  }

  void release() {
    for (final completer in _completer) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    _completer.clear();
  }

  void reject(Object error) {
    for (final completer in _completer) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    _completer.clear();
  }
}