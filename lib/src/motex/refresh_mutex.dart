import 'dart:async';

class RefreshMutex {
  Completer<void>? _completer;

  bool get isLocked => _completer != null;

  Future<void> wait() async {
    if (_completer == null) return;

    await _completer!.future;
  }

  void lock() {
    if (_completer == null) {
      _completer = Completer<void>();
    }
  }

  void unlock() {
    _completer?.complete();
    _completer = null;
  }

  void reject(Object error) {
    _completer?.completeError(error);
    _completer = null;
  }
}