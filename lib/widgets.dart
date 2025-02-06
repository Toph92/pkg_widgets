library pkg_widgets;

import 'package:flutter/material.dart';
/* import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io'; */
import 'package:flutter/foundation.dart';

class OS {
  static bool isMobile() {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }
    return false;
  }

  static bool isWeb() {
    if (kIsWeb) return true;
    return false;
  }

  static bool isDesktop() {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) return true;
    return false;
  }

  static bool isAndroid() {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) return true;
    return false;
  }

  static bool isIOS() {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS) return true;
    return false;
  }

  static bool isLinux() {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.linux) return true;
    return false;
  }

  static bool isWindows() {
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
