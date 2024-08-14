import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static int spaceShipCenter = 670;
  static int numberOfSquares = 700;
  static bool alienGotHit = false;
  static bool playerGotHit = false;
  var myGoogleFont = GoogleFonts.orbitron(
    textStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 30,
    ),
  );

  static List<int> spaceship = [
    spaceShipCenter - 21,
    spaceShipCenter - 20,
    spaceShipCenter - 19,
    spaceShipCenter - 1,
    spaceShipCenter,
    spaceShipCenter + 1,
    spaceShipCenter + 2
  ];

  List<int> barriers = [
    numberOfSquares - 160 + 2,
    numberOfSquares - 160 + 3,
    numberOfSquares - 160 + 4,
    numberOfSquares - 160 + 5,
    numberOfSquares - 160 + 8,
    numberOfSquares - 160 + 9,
    numberOfSquares - 160 + 10,
    numberOfSquares - 160 + 11,
    numberOfSquares - 160 + 14,
    numberOfSquares - 160 + 15,
    numberOfSquares - 160 + 16,
    numberOfSquares - 160 + 17,
    numberOfSquares - 140 + 2,
    numberOfSquares - 140 + 3,
    numberOfSquares - 140 + 4,
    numberOfSquares - 140 + 5,
    numberOfSquares - 140 + 8,
    numberOfSquares - 140 + 9,
    numberOfSquares - 140 + 10,
    numberOfSquares - 140 + 11,
    numberOfSquares - 140 + 14,
    numberOfSquares - 140 + 15,
    numberOfSquares - 140 + 16,
    numberOfSquares - 140 + 17,
  ];

  static int alienStartPos = 30;

  List<int> alien = [
    alienStartPos,
    alienStartPos + 1,
    alienStartPos + 2,
    alienStartPos + 3,
    alienStartPos + 4,
    alienStartPos + 5,
    alienStartPos + 6,
    alienStartPos + 1 + 20,
    alienStartPos + 2 + 20,
    alienStartPos + 3 + 20,
    alienStartPos + 4 + 20,
    alienStartPos + 5 + 20,
    alienStartPos + 6 + 20,
  ];

  int playerMissileShot = -1;
  int alienMissileShot = -1;
  String direction = 'left';
  bool timeForNextShot = false;
  bool alienGunAtBack = true;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    const durationFood = Duration(milliseconds: 700);
    Timer.periodic(
      durationFood,
          (Timer timer) {
        setState(() {
          alienMoves();
          if (timeForNextShot) {
            alienMissile();
            timeForNextShot = false;
          } else {
            timeForNextShot = true;
          }
        });
      },
    );
  }

  void alienMoves() {
    setState(() {
      if (direction == 'left' && (alien[0] - 1) % 20 == 0) {
        // Move aliens down and switch direction
        for (int i = 0; i < alien.length; i++) {
          alien[i] += 20; // Move down one row
        }
        direction = 'right';
      } else if (direction == 'right' && (alien.last + 1) % 20 == 19) {
        // Move aliens down and switch direction
        for (int i = 0; i < alien.length; i++) {
          alien[i] += 20; // Move down one row
        }
        direction = 'left';
      }

      // Move aliens left or right
      if (direction == 'right') {
        for (int i = 0; i < alien.length; i++) {
          alien[i] += 1;
        }
      } else {
        for (int i = 0; i < alien.length; i++) {
          alien[i] -= 1;
        }
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (spaceship.first % 20 != 0) {
        for (int i = 0; i < spaceship.length; i++) {
          spaceship[i] -= 1;
        }
      }
    });
  }

  void moveRight() {
    setState(() {
      if (spaceship.last % 20 != 19) {
        for (int i = 0; i < spaceship.length; i++) {
          spaceship[i] += 1;
        }
      }
    });
  }

  void updateDamage() {
    setState(() {
      if (alien.contains(playerMissileShot)) {
        alien.remove(playerMissileShot);
        playerMissileShot = -1;
        alienGotHit = true;
      }
      if (spaceship.contains(alienMissileShot)) {
        spaceship.remove(alienMissileShot);
        alienMissileShot = -1;
        playerGotHit = true;
      }
      if (barriers.contains(alienMissileShot)) {
        barriers.remove(alienMissileShot);
        alienMissileShot = -1;
      }
      if (playerMissileShot == alienMissileShot) {
        playerMissileShot = -1;
        alienMissileShot = -1;
        alienGotHit = true;
      }
      if (barriers.contains(playerMissileShot)) {
        playerMissileShot = -1;
        alienGotHit = true;
      }
    });
  }

  void fireMissile() {
    if (playerMissileShot == -1) {
      playerMissileShot = spaceship.first;
      alienGotHit = false;
      const durationMissile = Duration(milliseconds: 50);
      Timer.periodic(
        durationMissile,
            (Timer timer) {
          setState(() {
            playerMissileShot -= 20; // Move missile upwards
            updateDamage(); // Check for collisions
            // Stop the timer if missile goes off-screen or hits an alien
            if (playerMissileShot < 0 || alienGotHit) {
              playerMissileShot = -1;
              timer.cancel();
            }
          });
        },
      );
    }
  }

  void updateAlienMissile() {
    setState(() {
      alienMissileShot += 20;
      if (alienMissileShot > 700) {
        alienMissileShot = -1; // Reset missile after it goes off-screen
      }
    });
  }

  void alienMissile() {
    if (alienMissileShot == -1) {
      alienMissileShot = alienGunAtBack ? alien.last : alien.first;
      alienGunAtBack = !alienGunAtBack;
      const durationMissile = Duration(milliseconds: 100);
      Timer.periodic(durationMissile, (Timer timer) {
        setState(() {
          updateAlienMissile();
          updateDamage();
          if (alienMissileShot == -1) {
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 20,
                ),
                itemCount: numberOfSquares,
                itemBuilder: (BuildContext context, int index) {
                  if (alien.contains(index)) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        color: Colors.green,
                      ),
                    );
                  } else if (spaceship.contains(index)) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        color: Colors.white,
                      ),
                    );
                  } else if (barriers.contains(index)) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        color: Colors.blue,
                      ),
                    );
                  } else if (index == playerMissileShot) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        color: Colors.yellow,
                      ),
                    );
                  } else if (index == alienMissileShot) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        color: Colors.red,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: moveLeft,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    GestureDetector(
                      onTap: fireMissile,
                      child: const Icon(
                        Icons.flare,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    GestureDetector(
                      onTap: moveRight,
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
