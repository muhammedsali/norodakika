import 'package:flutter/material.dart';

class RadialGradientContainer extends StatelessWidget {
  const RadialGradientContainer({
    super.key,
    this.width,
    this.height,
    required this.startColor,
    required this.endColor,
  });

  final double? width;
  final double? height;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [
            startColor,
            endColor,
          ],
          stops: const [0.0, 0.8],
        ),
      ),
    );
  }
}
