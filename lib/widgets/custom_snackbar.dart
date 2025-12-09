import 'package:flutter/material.dart';

enum SnackbarType { success, warning, error }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    final snackbarConfig = _getSnackbarConfig(type);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final snackBar = SnackBar(
      content: _SnackbarContent(
        message: message,
        type: type,
        config: snackbarConfig,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      action: onActionPressed != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: snackbarConfig.actionTextColor,
              onPressed: onActionPressed,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static _SnackbarConfig _getSnackbarConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          backgroundColor: const Color(0xFF10B981),
          iconColor: Colors.white,
          textColor: Colors.white,
          actionTextColor: Colors.white,
          icon: Icons.check_circle_outline,
          shadowColor: const Color(0xFF10B981).withOpacity(0.3),
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          backgroundColor: const Color(0xFFF59E0B),
          iconColor: Colors.white,
          textColor: Colors.white,
          actionTextColor: Colors.white,
          icon: Icons.warning_amber_outlined,
          shadowColor: const Color(0xFFF59E0B).withOpacity(0.3),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          backgroundColor: const Color(0xFFEF4444),
          iconColor: Colors.white,
          textColor: Colors.white,
          actionTextColor: Colors.white,
          icon: Icons.error_outline,
          shadowColor: const Color(0xFFEF4444).withOpacity(0.3),
        );
    }
  }
}

class _SnackbarConfig {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color actionTextColor;
  final IconData icon;
  final Color shadowColor;

  _SnackbarConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.actionTextColor,
    required this.icon,
    required this.shadowColor,
  });
}

class _SnackbarContent extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final _SnackbarConfig config;

  const _SnackbarContent({
    required this.message,
    required this.type,
    required this.config,
  });

  @override
  State<_SnackbarContent> createState() => _SnackbarContentState();
}

class _SnackbarContentState extends State<_SnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.config.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.config.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      widget.config.icon,
                      color: widget.config.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.config.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
//////////////////////////////////////////
//exampleusage
// Form validation error
// void _showValidationError() {
//   CustomSnackbar.show(
//     context,
//     message: 'Please fill all required fields',
//     type: SnackbarType.error,
//   );
// }

// // API success response
// void _showSaveSuccess() {
//   CustomSnackbar.show(
//     context,
//     message: 'Profile updated successfully!',
//     type: SnackbarType.success,
//   );
// }

// // Network warning
// void _showNetworkWarning() {
//   CustomSnackbar.show(
//     context,
//     message: 'Slow network detected',
//     type: SnackbarType.warning,
//     actionLabel: 'Settings',
//     onActionPressed: () => Navigator.pushNamed(context, '/settings'),
//   );
// }