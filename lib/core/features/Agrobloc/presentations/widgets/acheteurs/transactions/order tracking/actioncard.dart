import 'package:flutter/material.dart';

enum ActionButtonType {
  primary,
  secondary,
  danger,
  success,
}

class ActionButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final bool isEnabled;
  final double? width;
  final double height;

  const ActionButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ActionButtonType.primary,
    this.isEnabled = true,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!isEnabled) return Colors.grey.shade300;
    
    switch (type) {
      case ActionButtonType.primary:
        return Colors.blue.shade600;
      case ActionButtonType.secondary:
        return Colors.grey.shade600;
      case ActionButtonType.danger:
        return const Color(0xFFB85450); // Rouge brique comme dans l'image
      case ActionButtonType.success:
        return const Color(0xFF9CAF88); // Vert clair comme dans l'image
    }
  }
}
