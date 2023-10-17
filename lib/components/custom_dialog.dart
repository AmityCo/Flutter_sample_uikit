import 'package:flutter/material.dart';

class TimedDialog extends StatefulWidget {
  final String text;
  const TimedDialog({super.key, required this.text});

  @override
  _TimedDialogState createState() => _TimedDialogState();
}

class _TimedDialogState extends State<TimedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // duration of the fade-out
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);

    // Wait for 3 seconds before starting the fade-out
    Future.delayed(const Duration(seconds: 2), () {
      _controller.forward().then((_) {
        Navigator.of(context).pop(); // Close dialog after animation
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Don't forget to dispose of the controller!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        child: Dialog(
          elevation: 0,
          child: AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
