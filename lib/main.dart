import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(SnakeGame());

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  List<Offset> snake = [Offset(10, 10)];
  Offset food = Offset(15, 15);
  bool gameOver = false;
  Timer? timer;
  final random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      if (!gameOver) moveSnake();
    });
  }

  void moveSnake() {
    final head = snake.first;
    snake.insert(0, Offset(head.dx + 1, head.dy));
    
    if ((food - head).distance < 1) {
      food = Offset(random.nextInt(30).toDouble(), random.nextInt(30).toDouble());
    } else {
      snake.removeLast();
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomPaint(
          size: Size.infinite,
          painter: SnakePainter(snake, food, gameOver),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: gameOver ? () => setState(() {
            snake = [Offset(10, 10)];
            food = Offset(15, 15);
            gameOver = false;
            startGame();
          }) : null,
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final bool gameOver;

  SnakePainter(this.snake, this.food, this.gameOver);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 30;
    
    // Snake
    final snakePaint = Paint()..color = Colors.green;
    for (var segment in snake) {
      canvas.drawRect(
        Rect.fromLTWH(segment.dx * cellSize, segment.dy * cellSize, cellSize, cellSize),
        snakePaint,
      );
    }
    
    // Food
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize),
      foodPaint,
    );
    
    if (gameOver) {
      final textPainter = TextPainter(
        text: TextSpan(text: 'GAME OVER\nTap REFRESH', style: TextStyle(color: Colors.white, fontSize: 30)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width/2 - 100, size.height/2 - 50));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}