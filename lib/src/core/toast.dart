library oktoast;

import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:oktoast/src/widget/overlay.dart';
import 'package:oktoast/oktoast.dart';

import 'position.dart';
import 'toast_manager.dart';

part '../widget/container.dart';

part '../widget/oktoast.dart';

part '../widget/theme.dart';

part 'toast_future.dart';

LinkedHashMap<_OKToastState, BuildContext> _contextMap = LinkedHashMap();
const _defaultDuration = Duration(
  milliseconds: 2300,
);

/// show toast with [msg],
ToastFuture showToast(String msg, {
  BuildContext context,
  Duration duration,
  ToastPosition position,
  TextStyle textStyle,
  EdgeInsetsGeometry textPadding,
  Color backgroundColor,
  double radius,
  VoidCallback onDismiss,
  TextDirection textDirection,
  bool dismissOtherToast,
  TextAlign textAlign,
  OKToastAnimationBuilder animationBuilder,
  Duration animationDuration,
  Curve animationCurve,
  EdgeInsetsGeometry toastMargin,
  bool fullWidth,
}) {
  context ??= _contextMap.values.first;

  final theme = _ToastTheme.of(context);
  textStyle ??= theme.textStyle ?? TextStyle(fontSize: 15.0);
  textAlign ??= theme.textAlign;
  textPadding ??= theme.textPadding;
  position ??= theme.position;
  backgroundColor ??= theme.backgroundColor;
  radius ??= theme.radius;
  textDirection ??= theme.textDirection ?? TextDirection.ltr;
  toastMargin ??= EdgeInsets.all(50.0);
  fullWidth ??= false;

  Widget widget = fullWidth ? Row(
    children: <Widget>[
      Expanded(
          child: Container(
            margin: toastMargin,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: textPadding,
            child: ClipRect(
              child: Text(
                msg,
                style: textStyle,
                textAlign: textAlign,
              ),
            ),
          )
      ),
    ],
  ) : Container(
    margin: toastMargin,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
    ),
    padding: textPadding,
    child: ClipRect(
      child: Text(
        msg,
        style: textStyle,
        textAlign: textAlign,
      ),
    ),
  );

  return showToastWidget(
    widget,
    animationBuilder: animationBuilder,
    context: context,
    duration: duration,
    onDismiss: onDismiss,
    position: position,
    dismissOtherToast: dismissOtherToast,
    textDirection: textDirection,
    animationCurve: animationCurve,
  );
}

/// show [widget] with oktoast
ToastFuture showToastWidget(Widget widget, {
  BuildContext context,
  Duration duration,
  ToastPosition position,
  VoidCallback onDismiss,
  bool dismissOtherToast,
  TextDirection textDirection,
  bool handleTouch,
  OKToastAnimationBuilder animationBuilder,
  Duration animationDuration,
  Curve animationCurve,
}) {
  context ??= _contextMap.values.first;
  OverlayEntry entry;
  ToastFuture future;
  final theme = _ToastTheme.of(context);

  position ??= theme.position;
  handleTouch ??= theme.handleTouch;
  animationBuilder ??= theme.animationBuilder;
  animationDuration ??=
      theme.animationDuration ?? const Duration(milliseconds: 250);
  animationCurve ??= theme.animationCurve ?? Curves.easeIn;
  duration ??= theme.duration ?? _defaultDuration;

  final movingOnWindowChange = theme?.movingOnWindowChange ?? false;

  final direction = textDirection ?? theme.textDirection ?? TextDirection.ltr;

  GlobalKey<__ToastContainerState> key = GlobalKey();

  widget = Align(
    child: widget,
    alignment: position.align,
  );

  entry = OverlayEntry(builder: (ctx) {
    return IgnorePointer(
      ignoring: !handleTouch,
      child: Directionality(
        textDirection: direction,
        child: _ToastContainer(
          duration: duration,
          position: position,
          movingOnWindowChange: movingOnWindowChange,
          key: key,
          child: widget,
          animationBuilder: animationBuilder,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
        ),
      ),
    );
  });

  dismissOtherToast ??= theme.dismissOtherOnShow ?? false;

  if (dismissOtherToast == true) {
    ToastManager().dismissAll();
  }

  future = ToastFuture._(entry, onDismiss, key, animationDuration);

  future.timer = Timer(duration, (){
    future.dismiss();
  });

  Overlay.of(context).insert(entry);
  ToastManager().addFuture(future);

  return future;
}

/// use the method to dismiss all toast.
void dismissAllToast({bool showAnim = false}) {
  ToastManager().dismissAll(showAnim: showAnim);
}
