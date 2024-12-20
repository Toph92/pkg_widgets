import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Preferences<T extends Enum> with ChangeNotifier {
  final Map<T, dynamic> prefs = {};
  late SharedPreferences sharedPrefs;
  bool _initDone = false;
  final List<T> enumValues;
  String sErrorMessage = '';

  Preferences({required this.enumValues}) {
    assert(enumValues.isNotEmpty, 'enumValues must not be empty');
    assert(T != Enum);
  }

  @override
  dispose() {
    prefs.clear();
    sharedPrefs.clear();
    super.dispose();
  }

  Future<bool> initialize() async {
    try {
      sharedPrefs = await SharedPreferences.getInstance();
      // Charger les préférences existantes
      for (var key in enumValues) {
        final keyString = key.toString();
        if (sharedPrefs.containsKey(keyString)) {
          if (sharedPrefs.get(keyString) is bool) {
            prefs[key] = sharedPrefs.getBool(keyString);
          } else if (sharedPrefs.get(keyString) is String) {
            prefs[key] = sharedPrefs.getString(keyString);
          } else if (sharedPrefs.get(keyString) is double) {
            prefs[key] = sharedPrefs.getDouble(keyString);
          }
        }
      }
      _initDone = true;
      return true;
    } catch (e) {
      sErrorMessage = 'Erreur lors de l\'initialisation des préférences : $e';
      print(sErrorMessage);
      return false;
    }
  }

  dynamic operator [](T key) {
    assert(T != Enum);
    return prefs[key];
  }

  void operator []=(T key, dynamic value) {
    assert(_initDone, 'Preferences not initialized');
    prefs[key] = value;

    final keyString = key.toString();
    if (value is bool) {
      sharedPrefs.setBool(keyString, value);
    } else if (value is String) {
      sharedPrefs.setString(keyString, value);
    } else if (value is double) {
      sharedPrefs.setDouble(keyString, value);
    } else if (value == null) {
      sharedPrefs.remove(keyString);
    } else {
      throw ArgumentError('Type non supporté pour SharedPreferences : $value');
    }
    notifyListeners();
    //print('Préférence $key mise à jour à $value');
  }
}
