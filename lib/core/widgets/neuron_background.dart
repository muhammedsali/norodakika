import 'package:flutter/material.dart';
import 'dart:math';

class NeuronBackground extends StatefulWidget {
  final bool isDarkMode;
  
  const NeuronBackground({super.key, required this.isDarkMode});

  @override
  State<NeuronBackground> createState() => _NeuronBackgroundState();
}

class _NeuronBackgroundState extends State<NeuronBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Node> _nodes = [];
  final Random _random = Random();
  final int _nodeCount = 25; // Ekranda süzülen toplam nöron sayısı
  final double _maxDistance = 140.0; // Ağların(çizgilerin) birleşme mesafesi

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 10),
    )..addListener(() {
        _updateNodes();
        setState(() {}); // Painter'ı yeniden çiz
    });
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nodes.isEmpty) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < _nodeCount; i++) {
        _nodes.add(Node(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          vx: (_random.nextDouble() - 0.5) * 1.5,
          vy: (_random.nextDouble() - 0.5) * 1.5,
        ));
      }
    }
  }

  void _updateNodes() {
    final size = MediaQuery.of(context).size;
    for (var node in _nodes) {
      node.x += node.vx;
      node.y += node.vy;

      // Sınır Çarpmaları (Bouncing off walls)
      if (node.x <= 0 || node.x >= size.width) node.vx *= -1;
      if (node.y <= 0 || node.y >= size.height) node.vy *= -1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: NeuronPainter(
          nodes: _nodes,
          maxDistance: _maxDistance,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }
}

class Node {
  double x, y;
  double vx, vy;
  Node({required this.x, required this.y, required this.vx, required this.vy});
}

class NeuronPainter extends CustomPainter {
  final List<Node> nodes;
  final double maxDistance;
  final bool isDarkMode;

  NeuronPainter({required this.nodes, required this.maxDistance, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Temel Renk Tonlamasına Karar Ver:
    const primaryColor = Color(0xFF0D59F2);
    // Dark mode'da çok dikkat dağıtmaması için biraz saydamlaştırıyoruz (alpha değeri)
    final nodeColor = isDarkMode ? Colors.white.withValues(alpha: 0.25) : primaryColor.withValues(alpha: 0.15);

    final nodePaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Uzaktaki ağları çizer
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dx = nodes[i].x - nodes[j].x;
        final dy = nodes[i].y - nodes[j].y;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < maxDistance) {
           // Mesafeye göre opacity (şeffaflık) azalt/çoğalt
           final opacityRate = 1.0 - (distance / maxDistance);
           final baseAlpha = isDarkMode ? 0.1 : 0.05;
           linePaint.color = (isDarkMode ? Colors.white : primaryColor).withValues(alpha: baseAlpha * opacityRate);
           canvas.drawLine(
             Offset(nodes[i].x, nodes[i].y), 
             Offset(nodes[j].x, nodes[j].y), 
             linePaint
           );
        }
      }
    }

    // Nöron (Node) noktalarını çizer
    for (var node in nodes) {
      canvas.drawCircle(Offset(node.x, node.y), 3.0, nodePaint);
      
      // Işıltı (Glow efekti)
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha: isDarkMode ? 0.1 : 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(node.x, node.y), 8.0, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant NeuronPainter oldDelegate) => true; // Sürekli hareket olduğu için hep güncellenir
}
