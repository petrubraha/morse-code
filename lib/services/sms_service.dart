import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('sms_channel');
  static StreamController<String>? _incomingSmsController;

  static Stream<String> get incomingSms {
    _incomingSmsController ??= StreamController<String>.broadcast();
    return _incomingSmsController!.stream;
  }

  static void initialize() {
    _incomingSmsController ??= StreamController<String>.broadcast();
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onSmsReceived') {
      final message = call.arguments as String? ?? '';
      _incomingSmsController?.add(message);
    }
  }

  static Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      await _channel.invokeMethod('sendSms', {
        'phone': phoneNumber,
        'message': message,
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint('SMS send error: $e');
      return false;
    }
  }

  static void dispose() {
    _incomingSmsController?.close();
    _incomingSmsController = null;
  }
}
