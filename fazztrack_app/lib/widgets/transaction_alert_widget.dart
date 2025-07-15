import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fazztrack_app/constants/colors_constants.dart';

class TransactionAlertWidget extends StatefulWidget {
  final String title;
  final String message;
  final bool isError;
  final int autoDismissDuration;

  const TransactionAlertWidget({
    super.key,
    required this.title,
    required this.message,
    required this.isError,
    this.autoDismissDuration = 1,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    bool isError = false,
    int autoDismissDuration = 1,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => TransactionAlertWidget(
            title: title,
            message: message,
            isError: isError,
            autoDismissDuration: autoDismissDuration,
          ),
    );
  }

  @override
  State<TransactionAlertWidget> createState() => _TransactionAlertWidgetState();
}

class _TransactionAlertWidgetState extends State<TransactionAlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();

    if (!widget.isError) {
      _dismissTimer = Timer(Duration(seconds: widget.autoDismissDuration), () {
        _dismiss();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        widget.isError ? AppColors.error : AppColors.success;
    final IconData alertIcon =
        widget.isError ? Icons.error_outline : Icons.check_circle_outline;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha(30),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: primaryColor.withAlpha(50), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(10),
                  shape: BoxShape.circle,
                ),
                child: Icon(alertIcon, color: primaryColor, size: 48),
              ),
              const SizedBox(height: 16),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              widget.isError
                  ? ElevatedButton(
                    onPressed: _dismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size(120, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                  : _AutoDismissIndicator(
                    duration: widget.autoDismissDuration,
                    color: primaryColor,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoDismissIndicator extends StatefulWidget {
  final int duration;
  final Color color;

  const _AutoDismissIndicator({required this.duration, required this.color});

  @override
  State<_AutoDismissIndicator> createState() => _AutoDismissIndicatorState();
}

class _AutoDismissIndicatorState extends State<_AutoDismissIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.5),
        child: LinearProgressIndicator(
          value: 1 - _controller.value,
          backgroundColor: widget.color.withAlpha(20),
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        ),
      ),
    );
  }
}
