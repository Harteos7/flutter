import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'dart:math';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  await const FirebaseOptions(
  apiKey: "AIzaSyBUiuITIqoTjhhIKaUfyvzaGgqREvMoGow",
  authDomain: "snake-1fdc7.firebaseapp.com",
  projectId: "snake-1fdc7",
  storageBucket: "snake-1fdc7.appspot.com",
  messagingSenderId: "490930402290",
  appId: "1:490930402290:web:f0bd3c6234de7b6983716b",
  measurementId: "G-VVWNWRSZ07"
);
  runApp(MyApp()); 
}

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
  final fontStyle = const TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();
  String? _message; // the keyboard Listener
  var duration = const Duration(milliseconds: 500); // time for a mouve
  var duration2 = const Duration(milliseconds: 500); // time for a mouve
  
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
    snakeTime();
  }

  void snakeTime() {
    Timer.periodic(duration, (Timer timer) {
      print(snake);
      print(duration);
      print('direction =' + direction);
      moveSnake(duration2);
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
      if (duration > duration2) {
        if ( isPlaying = true ) {
        duration = duration2 ;
        timer.cancel();
        snakeTime();
        }
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
        duration2 = duration2 - const Duration(milliseconds: 50);
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
    duration = const Duration(milliseconds: 500);
    duration2 = const Duration(milliseconds: 500);
    isPlaying = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tes nul LOL'),
          content: Text(
            'Score: ${snake.length - 2}',
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
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
                    physics: const NeverScrollableScrollPhysics(),
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
                        margin: const EdgeInsets.all(1),
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
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: isPlaying ? Colors.red : Colors.blue,
                      ),
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