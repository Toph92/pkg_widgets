library pkg_widgets;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class OS {
  static bool isMobile() {
    if (kIsWeb) return false;
    if (Platform.isAndroid || Platform.isIOS) return true;
    return false;
  }

  static bool isWeb() {
    if (kIsWeb) return true;
    return false;
  }

  static bool isDesktop() {
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) return true;
    return false;
  }

  static bool isAndroid() {
    if (kIsWeb) return false;
    if (Platform.isAndroid) return true;
    return false;
  }

  static bool isIOS() {
    if (kIsWeb) return false;
    if (Platform.isIOS) return true;
    return false;
  }

  static bool isLinux() {
    if (kIsWeb) return false;
    if (Platform.isLinux) return true;
    return false;
  }

  static bool isWindows() {
    if (kIsWeb) return false;
    if (Platform.isWindows) return true;
    return false;
  }
}

SizedBox voidWidget() => const SizedBox.shrink();
