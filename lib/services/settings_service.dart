import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  static late Box _box;
  static const _boxName = 'settings';

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static ValueListenable<Box> listenable() {
    return _box.listenable();
  }

  static bool get isDarkMode =>
      _box.get('isDarkMode', defaultValue: true) as bool;

  static Future<void> setDarkMode(bool v) =>
      _box.put('isDarkMode', v);

  static double get baseFontSize =>
      (_box.get('baseFontSize', defaultValue: 16.0) as num).toDouble();

  static Future<void> setBaseFontSize(double v) =>
      _box.put('baseFontSize', v);

  static int get autoSaveInterval =>
      (_box.get('autoSaveInterval', defaultValue: 800) as num).toInt();

  static Future<void> setAutoSaveInterval(int v) =>
      _box.put('autoSaveInterval', v);

  static int get accentColorValue =>
      (_box.get('accentColor', defaultValue: 0xFFD3AC00) as num).toInt();

  static Future<void> setAccentColor(int v) =>
      _box.put('accentColor', v);

  static double get lineHeight =>
      (_box.get('lineHeight', defaultValue: 1.6) as num).toDouble();

  static Future<void> setLineHeight(double v) =>
      _box.put('lineHeight', v);

  static bool get showWordCount =>
      _box.get('showWordCount', defaultValue: true) as bool;

  static Future<void> setShowWordCount(bool v) =>
      _box.put('showWordCount', v);

  static Color get accentColor =>
      Color(accentColorValue);
}