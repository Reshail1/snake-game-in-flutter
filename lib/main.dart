import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  final textStyle = const TextStyle(color: Colors.white);
  final randomGen = Random();

  List<int> snakePosition = [45, 65, 85, 105, 125];
  var direction = 'down';
  int food = 60;

  void startGame() {
    snakePosition = [45, 65, 85, 105, 125];
    direction = 'down';

    const duration = Duration(milliseconds: 200);

    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        endGame();
      }
    });
    createFood();
  }

  void createFood() {
    food = randomGen.nextInt(squaresPerRow * squaresPerCol);
    while (snakePosition.contains(food)) {
      food = randomGen.nextInt(squaresPerRow * squaresPerCol);
    }
  }

 bool gameOver() {
    var headPos = snakePosition.last;
    if (direction == 'down' && (headPos + 20) >= squaresPerRow * squaresPerCol) return true;
    if (direction == 'up' && headPos < squaresPerRow) return true;
    if (direction == 'left' && headPos % squaresPerRow == 0) return true;
    if (direction == 'right' && (headPos + 1) % squaresPerRow == 0) return true;
    return false;
  }


void endGame() {
    var points = snakePosition.length - 5;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Points: $points'),
            actions: <Widget>[
              TextButton(
                child: Text('Play Again'),
                onPressed: () {
                  Navigator.pop(context);
                  startGame();
                },
              )
            ],
          );
        });
  }


  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snakePosition.last > squaresPerRow * (squaresPerCol - 1)) {
            snakePosition.add(snakePosition.last + 20 - (squaresPerRow * squaresPerCol));
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;
        case 'up':
          if (snakePosition.last < squaresPerRow) {
            snakePosition.add(snakePosition.last - 20 + (squaresPerRow * squaresPerCol));
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        case 'left':
          if (snakePosition.last % squaresPerRow == 0) {
            snakePosition.add(snakePosition.last - 1 + squaresPerRow);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % squaresPerRow == 0) {
            snakePosition.add(snakePosition.last + 1 - squaresPerRow);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
      }

      if (snakePosition.last == food) {
        createFood();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: squaresPerRow,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (snakePosition.contains(index)) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == food) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          color: Colors.grey[800],
                        ),
                      ),
                    );
                  }
                },
                itemCount: squaresPerRow * squaresPerCol,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: startGame,
                  child: Text('Start Game', style: textStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
