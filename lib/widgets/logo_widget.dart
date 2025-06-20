import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool showText;

  const LogoWidget({
    super.key,
    this.width = 150,
    this.height = 100,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image
        Container(
          width: width,
          height: height,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image doesn't load
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'DRIVE SMART',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      'ACCELERATE YOUR SKILLS',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LogoIconWidget extends StatelessWidget {
  final double size;

  const LogoIconWidget({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback icon
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car,
              color: Colors.white,
              size: size * 0.6,
            ),
          );
        },
      ),
    );
  }
}
