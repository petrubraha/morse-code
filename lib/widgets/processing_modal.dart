import 'package:flutter/material.dart';
import '../morse/morse_constants.dart';
import '../services/flash_service.dart';

class ProcessingModal extends StatefulWidget {
  final String plainText;
  final VoidCallback onComplete;

  const ProcessingModal({
    super.key,
    required this.plainText,
    required this.onComplete,
  });

  @override
  State<ProcessingModal> createState() => _ProcessingModalState();
}

class _ProcessingModalState extends State<ProcessingModal>
    with SingleTickerProviderStateMixin {
  String _currentChar = '';
  String _currentMorse = '';
  bool _isFlashOn = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startFlashing();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startFlashing() async {
    final input = widget.plainText;

    for (int i = 0; i < input.length; i++) {
      if (!mounted) return;

      final char = input[i].toUpperCase();
      final morse = morseEncryption[char];
      if (morse == null) continue;

      setState(() {
        _currentChar = char == ' ' ? '⎵' : char;
        _currentMorse = morse;
      });

      if (char == ' ') {
        await FlashService.wordGapPause();
        continue;
      }

      for (int j = 0; j < morse.length; j++) {
        if (!mounted) return;
        final signal = morse[j];

        if (mounted) {
          setState(() => _isFlashOn = true);
          _pulseController.forward();
        }

        await FlashService.flashSignal(signal);

        if (mounted) {
          setState(() => _isFlashOn = false);
          _pulseController.reverse();
        }

        // If it is not the last element, then wait a small gap.
        if (j < morse.length - 1) {
          await FlashService.interElementGap();
        }
      }

      if (i < input.length - 1 && input[i + 1] != ' ') {
        await FlashService.letterGapPause();
      }
    }

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F3460).withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TRANSMITTING',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isFlashOn
                          ? Color.lerp(
                              const Color(0xFF533483),
                              const Color(0xFFFFC107),
                              _pulseController.value,
                            )
                          : const Color(0xFF1A1A2E),
                      border: Border.all(
                        color: _isFlashOn
                            ? const Color(0xFFFFC107)
                            : Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: _isFlashOn
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFC107,
                                ).withValues(alpha: 0.6),
                                blurRadius: 30,
                                spreadRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: _isFlashOn
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      size: 36,
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                _currentChar,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  _currentMorse
                      .split('')
                      .map((s) {
                        if (s == dit) return '•';
                        if (s == dah) return '—';
                        return s;
                      })
                      .join(' '),
                  style: const TextStyle(
                    color: Color(0xFFE94560),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFE94560),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
