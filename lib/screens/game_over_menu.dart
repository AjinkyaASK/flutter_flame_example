import 'package:flutter/material.dart';

class GameOverMenu extends StatelessWidget {
  const GameOverMenu(
      {Key? key,
      this.width = double.maxFinite,
      this.height = double.maxFinite,
      this.onRestart,
      this.onExit})
      : super(key: key);

  final double width;
  final double height;
  final void Function()? onRestart;
  final void Function()? onExit;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        width: width,
        height: height,
        color: const Color.fromARGB(255, 100, 79, 149).withOpacity(0.75),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.only(bottom: 32.0),
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Game Over',
                    style: TextStyle(fontSize: 32.0, color: Colors.white),
                  ),
                ),
              ),
              // Resume Button
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 48.0,
                      )
                    ]),
                child: MaterialButton(
                  onPressed: onRestart,
                  elevation: 0.0,
                  color: Colors.white,
                  minWidth: 200.0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 16.0),
                  // color: Colors.white,
                  shape: const StadiumBorder(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.replay, size: 32.0),
                      ),
                      Text(
                        'Play Again',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                ),
              ),
              // Exit Button
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 48.0,
                      )
                    ]),
                child: MaterialButton(
                  onPressed: onExit,
                  elevation: 0.0,
                  color: Colors.grey.shade900,
                  minWidth: 200.0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 16.0),
                  shape: const StadiumBorder(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child:
                            Icon(Icons.close, color: Colors.white, size: 32.0),
                      ),
                      Text(
                        'Exit',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
