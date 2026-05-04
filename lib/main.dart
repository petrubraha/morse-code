import 'dart:async';
import 'package:flutter/material.dart';
import 'morse/morse_codec.dart';
import 'screens/message_screen.dart';
import 'screens/phone_screen.dart';
import 'services/flash_service.dart';
import 'services/sms_service.dart';
import 'widgets/notification_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlashService.initialize();
  SmsService.initialize();
  runApp(const MorseApp());
}

class MorseApp extends StatelessWidget {
  const MorseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF533483),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String? _phoneNumber;
  StreamSubscription<String>? _smsSub;

  @override
  void initState() {
    super.initState();
    _listenForSms();
  }

  void _listenForSms() {
    _smsSub = SmsService.incomingSms.listen((message) {
      _handleIncomingSms(message);
    });
  }

  void _handleIncomingSms(String message) {
    final overlay = NotificationOverlay.of(context);
    try {
      final decrypted = MorseCodec.decrypt(message);
      print(decrypted);
      overlay?.showSuccess('SMS received: $decrypted');
    } catch (_) {
      overlay?.showError('Received SMS but could not decrypt.');
    }
  }

  @override
  void dispose() {
    _smsSub?.cancel();
    SmsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: NotificationOverlay(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _phoneNumber == null
                  ? PhoneScreen(
                      key: const ValueKey('phone'),
                      onPhoneSubmitted: (phone) {
                        setState(() => _phoneNumber = phone);
                      },
                    )
                  : MessageScreen(
                      key: const ValueKey('message'),
                      phoneNumber: _phoneNumber!,
                      onBack: () {
                        setState(() => _phoneNumber = null);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
