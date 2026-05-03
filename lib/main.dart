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
  var direction = 1.0; // 1=right, -1=left
  bool justChanged = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer?.cancel();
    snake = [Offset(10, 10)];
    food = Offset(15, 15);
    direction = 1.0;
    gameOver = false;
    justChanged = false;
    timer = Timer.periodic(Duration(milliseconds: 200), (Timer t) {
      if (!gameOver) moveSnake();
    });
  }

  void moveSnake() {
    final head = snake.first;
    Offset newHead;
    
    // ONE BUTTON: Toggle left/right
    if (direction == 1) {
      newHead = Offset(head.dx + 1, head.dy);
    } else {
      newHead = Offset(head.dx - 1, head.dy);
    }

    // WALL COLLISION
    if (newHead.dx < 0 || newHead.dx > 29) {
      gameOver = true;
      setState(() {});
      return;
    }

    snake.insert(0, newHead);
    
    // EAT FOOD
    if ((food - head).distance < 1) {
      food = Offset(random.nextInt(29).toDouble(), random.nextInt(29).toDouble());
    } else {
      snake.removeLast();
    }

    // SELF COLLISION (skip head)
    for (int i = 1; i < snake.length; i++) {
      if ((snake[i] - newHead).distance < 0.5) {
        gameOver = true;
        setState(() {});
        return;
      }
    }
    
    justChanged = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: CustomPaint(
          size: Size.infinite,
          painter: SnakePainter(snake, food, gameOver),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            if (!gameOver) {
              direction = -direction; // Toggle direction
              justChanged = true;
            } else {
              startGame();
            }
          },
          child: gameOver 
            ? Icon(Icons.refresh, color: Colors.white) 
            : Icon(Icons.swap_horiz, color: Colors.white),
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
    
    // Snake (green)
    final snakePaint = Paint()..color = Colors.green;
    for (var segment in snake) {
      canvas.drawRect(
        Rect.fromLTWH(segment.dx * cellSize, segment.dy * cellSize, cellSize, cellSize),
        snakePaint,
      );
    }
    
    // Food (red)
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize),
      foodPaint,
    );
    
    if (gameOver) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'GAME OVER\nTAP SWAP TO RESTART', 
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width/2 - 120, size.height/2 - 40));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}