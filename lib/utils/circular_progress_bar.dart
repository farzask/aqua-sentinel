import 'package:flutter/material.dart';
import 'dart:math' as math;

//Actual Widget that we will use
class CircularProgressDisplay extends StatelessWidget {
  final double value; // e.g., 0.6 for 60%
  final String label; // e.g., '1200L'

  const CircularProgressDisplay({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Define a size for the circular bar
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // The CustomPaint for the Circular Bar
          CustomPaint(
            size: Size(150, 150),
            painter: CircularProgressPainter(
              progress: value,
              baseColor: Colors.grey.withOpacity(0.2), // Light gray/blue
              progressColor: Colors.blue, // Vibrant blue
              strokeWidth: 15.0,
            ),
          ),
          // The Text in the center
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SFProDisplay',
              color: Colors.blue,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

//Circular Progress Painter Class that Circular Progress Display Class will use
class CircularProgressPainter extends CustomPainter {
  final double progress; // The percentage of completion (0.0 to 1.0)
  final Color baseColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Setup for the full circle (the base/unfilled part)
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Use round caps for the ends

    // 2. Setup for the progress arc (the filled part)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // The center of the circle
    final center = Offset(size.width / 2, size.height / 2);
    // The radius of the circle
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    // Draw the full circle base arc
    // Start angle: -90 degrees (or -pi/2 radians) to start from the top
    const startAngle = -math.pi / 2;
    // Sweep angle: 360 degrees (or 2*pi radians)
    const sweepAngle = math.pi * 2;

    // Draw the full circle base arc (unfilled part)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false, // This must be false for stroke style
      basePaint,
    );

    // Draw the progress arc
    // The sweep angle is the progress percentage (0.0 to 1.0) multiplied by a full circle (2*pi)
    final progressSweepAngle = progress * sweepAngle;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweepAngle,
      false, // This must be false for stroke style
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    // Repaint only if the progress value changes
    return oldDelegate.progress != progress;
  }
}
