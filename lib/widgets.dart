library pkg_widgets;

import 'package:flutter/material.dart';
/* import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io'; */
import 'package:flutter/foundation.dart';

class OS {
  bool android = false;
  bool ios = false;
  bool linux = false;
  bool windows = false;
  bool macos = false;
  bool web = kIsWeb;

/*   OS() {
    if (kIsWeb) web = true;
    if (defaultTargetPlatform == TargetPlatform.android) android = true;
    if (defaultTargetPlatform == TargetPlatform.iOS) ios = true;
    if (defaultTargetPlatform == TargetPlatform.linux) linux = true;
    if (defaultTargetPlatform == TargetPlatform.windows) windows = true;
    if (defaultTargetPlatform == TargetPlatform.macOS) macos = true;
  } */
/*   mobile() {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }
    return false;
  } */

  static bool isMobile([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }
    return false;
  }

  static bool isWeb([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return true;
    return false;
  }

  /// return forceValue if not null otherwise right boolean
  static bool isDesktop([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return true;
    }
    return false;
  }

  static bool isAndroid([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) return true;
    return false;
  }

  static bool isIOS([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS) return true;
    return false;
  }

  static bool isLinux([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.linux) return true;
    return false;
  }

  static bool isWindows([bool? forceValue]) {
    if (forceValue != null) return forceValue;
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.windows) return true;
    return false;
  }
}

SizedBox voidWidget() => const SizedBox.shrink();

/// Create horizontal space of [pixels] between widgets
Widget hSpacer(double pixels) => SizedBox(
      width: pixels,
    ); // y'a une lib (Gap) qui fait le même truc mais bof, je garde mon truc

/// Create vertical space of [pixels] between widgets
Widget vSpacer(double pixels) => SizedBox(
      height: pixels,
    );

// marche plus trop ce truc. C'utilisé ?
mixin WidgetGetSizeOld<T extends StatefulWidget> on State<T> {
  final GlobalKey _keySize = GlobalKey();
  Size? _resultBoxSize;
  double _width = 0;
  double _height = 0;
  bool _initDone = false;

  void initGetSize() {
    _postFrameCallback();
    _initDone = true;
    super.initState();
  }

  Widget sizeBuilder(
      {required Widget Function(BuildContext, Size, Key) builder}) {
    assert(_initDone,
        "You must call initGetSize() in initState() before using sizeBuilder()");
    return Builder(
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth != _width ||
                constraints.maxHeight != _height) {
              _width = constraints.maxWidth;
              _height = constraints.maxHeight;
              _postFrameCallback();
            }
            return builder(context, _resultBoxSize ?? Size.zero, _keySize);
          },
        );
      },
    );
  }

  _postFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        assert(
            _keySize.currentContext != null, "check if key is used in parent");
        setState(() {
          _resultBoxSize = _getRedBoxSize(_keySize.currentContext!);
        });
      }
    });
  }

  Size _getRedBoxSize(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    return box.size;
  }
}
