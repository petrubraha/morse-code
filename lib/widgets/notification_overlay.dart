import 'dart:async';
import 'package:flutter/material.dart';

class NotificationOverlay extends StatefulWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  static NotificationOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<NotificationOverlayState>();
  }

  @override
  NotificationOverlayState createState() => NotificationOverlayState();
}

class NotificationOverlayState extends State<NotificationOverlay>
    with SingleTickerProviderStateMixin {
  final List<_NotificationEntry> _notifications = [];
  int _idCounter = 0;

  void showMessage(String message, {bool isError = false}) {
    final id = _idCounter++;
    setState(() {
      _notifications.add(
        _NotificationEntry(id: id, message: message, isError: isError),
      );
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
        });
      }
    });
  }

  void showError(String message) => showMessage(message, isError: true);
  void showSuccess(String message) => showMessage(message);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: _notifications.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _NotificationCard(entry: entry),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _NotificationEntry {
  final int id;
  final String message;
  final bool isError;

  _NotificationEntry({
    required this.id,
    required this.message,
    required this.isError,
  });
}

class _NotificationCard extends StatefulWidget {
  final _NotificationEntry entry;

  const _NotificationCard({required this.entry});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.entry.isError;
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError
                  ? const Color(0xFF2D1B1B)
                  : const Color(0xFF1B2D1B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isError
                    ? const Color(0xFFCF6679)
                    : const Color(0xFF66BB6A),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: isError
                      ? const Color(0xFFCF6679)
                      : const Color(0xFF66BB6A),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.entry.message,
                    style: TextStyle(
                      color: isError
                          ? const Color(0xFFFFCDD2)
                          : const Color(0xFFC8E6C9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
