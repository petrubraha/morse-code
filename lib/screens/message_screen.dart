import 'package:flutter/material.dart';
import '../morse/morse_codec.dart';
import '../morse/morse_constants.dart';
import '../services/sms_service.dart';
import '../widgets/notification_overlay.dart';
import '../widgets/processing_modal.dart';

class MessageScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onBack;

  const MessageScreen({
    super.key,
    required this.phoneNumber,
    required this.onBack,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _controller = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isProcessing) return;
    final text = _controller.text.trim();
    final overlay = NotificationOverlay.of(context);

    if (text.isEmpty) {
      overlay?.showError('Please enter a message.');
      return;
    }

    final sanitized = MorseCodec.sanitize(text);
    for (final char in sanitized.toUpperCase().split('')) {
      if (morseEncryption[char] == null) {
        overlay?.showError('Unsupported character: "$char"');
        return;
      }
    }

    overlay?.showSuccess('Encoding message...');
    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => ProcessingModal(
        plainText: sanitized,
        charToMorse: morseEncryption,
        onComplete: () => _onFlashingComplete(sanitized),
      ),
    );
  }

  Future<void> _onFlashingComplete(String plainText) async {
    if (!mounted) return;
    Navigator.of(context).pop();
    final overlay = NotificationOverlay.of(context);

    try {
      final encrypted = MorseCodec.encrypt(plainText);
      final sent = await SmsService.sendSms(
        phoneNumber: widget.phoneNumber,
        message: encrypted,
      );
      if (sent) {
        overlay?.showSuccess('SMS sent successfully.');
      } else {
        overlay?.showError('Failed to send SMS.');
      }
    } catch (e) {
      overlay?.showError('Encryption error: $e');
    }

    setState(() => _isProcessing = false);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE94560).withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.edit_note, size: 56, color: Color(0xFFE94560)),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Compose Message',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text('To: ${widget.phoneNumber}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE94560).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, size: 22),
                        const SizedBox(width: 8),
                        Text(_isProcessing ? 'Processing...' : 'Flash & Send',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            onPressed: _isProcessing ? null : widget.onBack,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.7), size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
