import 'toast.dart';

class ToastManager {
  static ToastManager? _instance;

  ToastManager._();

  factory ToastManager() {
    _instance ??= ToastManager._();
    return _instance!;
  }

  Set<ToastFuture> toastSet = Set();

  void dismissAll({bool showAnim = false}) {
    toastSet.toList().forEach((v) {
      v.dismiss(showAnim: showAnim);
    });
  }

  void removeFuture(ToastFuture future) {
    toastSet.remove(future);
  }

  void addFuture(ToastFuture future) {
    toastSet.add(future);
  }
}
