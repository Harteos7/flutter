import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  final fontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();
  String? _message; // the keyboard Listener
  var duration = Duration(milliseconds: 500); // time for a mouve

  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var direction = 'up'; // first direction 
  var isPlaying = false; // var for the game

  void startGame() {

    snake = [ // Snake head
      [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor()]
    ];

    snake.add([snake.first[0], snake.first[1]+1]); // Snake body

    createFood();

    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      print(snake);
      print(duration);
      print('direction =' + direction);
      moveSnake(duration);
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake(var duration) { //Whe move the snake by the var direction and if the snake is not eating he loose the last circle of his body
    setState(() {
      switch(direction) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        
        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;

        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;

        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;

      }
      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast(); // function to lose weight
      } else {
        createFood(); // we multiply the bread
        duration = duration - Duration(milliseconds: 50);
        print(duration);
      }
    });
  }

  void createFood() {
    food = [
      randomGen.nextInt(squaresPerRow),
      randomGen.nextInt(squaresPerCol)
    ];
  }

  bool checkGameOver() { 
    if (!isPlaying // We check that we are not out of the field
      || snake.first[1] < 0
      || snake.first[1] >= squaresPerCol
      || snake.first[0] < 0
      || snake.first[0] > squaresPerRow
    ) {
      return true;
    }

    for(var i=1; i < snake.length; ++i) { // Check that the snake still has weight
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tes nul LOL'),
          content: Text(
            'Score: ${snake.length - 2}',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (RawKeyEvent event,) {
            // Handle the key event here
            if (event is RawKeyDownEvent) {
              _message = '${event.logicalKey.debugName}';
              print(_message);
              if (_message == 'Arrow Up' ) {
                direction = 'up';    
              }
              if (_message == 'Arrow Left') {
                direction = 'left';    
              }  
              if (_message == 'Arrow Right' ) {
                direction = 'right';    
              }
              if (_message == 'Arrow Down') {
                direction = 'down';             
              }
            }
          },
            child: AspectRatio(
              aspectRatio: squaresPerRow / (squaresPerCol + 5),
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: squaresPerRow,
                    ),
                    itemCount: squaresPerRow * squaresPerCol,
                    itemBuilder: (BuildContext context, int index) {
                      var color;
                      var x = index % squaresPerRow;
                      var y = (index / squaresPerRow).floor();

                      bool isSnakeBody = false;
                      for (var pos in snake) {
                        if (pos[0] == x && pos[1] == y) {
                          isSnakeBody = true;
                          break;
                        }
                      }

                      if (snake.first[0] == x && snake.first[1] == y) {
                        color = Colors.green;
                      } else if (isSnakeBody) {
                        color = Colors.green[200];
                      } else if (food[0] == x && food[1] == y) {
                        color = Colors.red;
                      } else {
                        color = Colors.grey[800];
                      }

                      return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: isPlaying ? Colors.red : Colors.blue,
                      ), // 
                      child: Text(
                        isPlaying ? 'Start' : 'Start',
                        style: fontStyle,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          isPlaying = false;
                        } else {
                          startGame();
                        }
                      }),
                  Text(
                    'Score: ${snake.length - 2}',
                    style: fontStyle,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}