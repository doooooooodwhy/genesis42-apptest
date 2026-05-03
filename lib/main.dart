import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(GameApp());

class GameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SnakeGame());
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  List<Offset> snake = [Offset(5, 5)];
  Offset direction = Offset(1, 0);
  Offset food;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    food = Offset(10, 10);
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!gameOver) setState(moveSnake);
    });
  }

  void moveSnake(Timer t) {
    Offset head = snake.first + direction;
    if (head.dx < 0 || head.dx >= 20 || head.dy < 0 || head.dy >= 20 ||
        snake.contains(head)) {
      gameOver = true;
      return;
    }
    snake.insert(0, head);
    if (head == food) {
      food = Offset(Random().nextInt(20), Random().nextInt(20));
    } else {
      snake.removeLast();
    }
  }

  void changeDirection(Offset newDir) {
    if ((newDir.dx != -direction.dx || newDir.dy != -direction.dy) && !gameOver)
      direction = newDir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(gameOver ? 'Game Over!' : 'Snake')),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 10) changeDirection(Offset(1, 0));
          else if (details.delta.dx < -10) changeDirection(Offset(-1, 0));
          else if (details.delta.dy > 10) changeDirection(Offset(0, 1));
          else if (details.delta.dy < -10) changeDirection(Offset(0, -1));
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: SnakePainter(snake, food, gameOver),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: gameOver ? () => setState(() {
          snake