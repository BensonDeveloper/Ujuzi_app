import 'package:flutter/material.dart';

class CustomAppBarPainter extends CustomPainter {
  final double height;

  CustomAppBarPainter({required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.deepOrangeAccent;
    paint.style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height); // Start from bottom left corner
    path.quadraticBezierTo(size.width / 2, size.height - height, size.width,
        size.height); // Create a quadratic bezier curve
    path.lineTo(size.width, 0); // Go to top right corner
    path.lineTo(0, 0); // Go to top left corner
    path.close(); // Close the path

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
