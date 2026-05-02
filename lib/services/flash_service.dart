import 'package:flutter/foundation.dart';
import 'package:torch_light/torch_light.dart';
import '../morse/morse_constants.dart';

class FlashService {
  static const int _unitDurationMs = 200;

  static bool _isFlashAvailable = false;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      _isFlashAvailable = await TorchLight.isTorchAvailable();
    } catch (_) {
      _isFlashAvailable = false;
    }
    _initialized = true;
  }

  static Future<void> _turnOn() async {
    if (!_isFlashAvailable) return;
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      debugPrint('Flash enable error: $e');
    }
  }

  static Future<void> _turnOff() async {
    if (!_isFlashAvailable) return;
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      debugPrint('Flash disable error: $e');
    }
  }

  static Future<void> flashSignal(String signal) async {
    if (signal == dit) {
      await _turnOn();
      await Future.delayed(Duration(milliseconds: _unitDurationMs));
      await _turnOff();
    } else if (signal == dah) {
      await _turnOn();
      await Future.delayed(Duration(milliseconds: _unitDurationMs * 3));
      await _turnOff();
    }
  }

  static Future<void> interElementGap() async {
    await Future.delayed(Duration(milliseconds: _unitDurationMs));
  }

  static Future<void> letterGapPause() async {
    await Future.delayed(Duration(milliseconds: _unitDurationMs * 3));
  }

  static Future<void> wordGapPause() async {
    await Future.delayed(Duration(milliseconds: _unitDurationMs * 7));
  }
}
