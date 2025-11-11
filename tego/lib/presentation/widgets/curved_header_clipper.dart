import 'package:flutter/material.dart';

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // Start from top left
    path.lineTo(0, 0);
    
    // Draw to top right
    path.lineTo(size.width, 0);
    
    // Draw to bottom right
    path.lineTo(size.width, size.height);
    
    // Create curved bottom edge (inward curve - concave)
    path.quadraticBezierTo(
      size.width * 0.5, // Control point X (middle)
      size.height - 80, // Control point Y (deeper inward curve)
      0, // End point X (left edge)
      size.height, // End point Y
    );
    
    // Close the path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}