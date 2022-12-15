import 'package:flutter/material.dart';

import '../main.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/background/background_layer_1.png',
            fit: BoxFit.fill,
          ),
          // Content
          Container(
            color: const Color.fromARGB(255, 100, 79, 149).withOpacity(0.75),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Game Title
                  const Padding(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        'Wood Runner',
                        style: TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Play Now Button
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
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const GameScreen()));
                      },
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
                            child: Icon(Icons.play_arrow, size: 32.0),
                          ),
                          Text(
                            'Play Now',
                            style: TextStyle(fontSize: 24.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // // Settings Button
                  // Container(
                  //   margin: const EdgeInsets.only(top: 16.0),
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(200),
                  //       boxShadow: const [
                  //         BoxShadow(
                  //           color: Colors.black26,
                  //           blurRadius: 48.0,
                  //         )
                  //       ]),
                  //   child: MaterialButton(
                  //     onPressed: () {
                  //       Navigator.of(context).push(MaterialPageRoute(
                  //           builder: (context) => const SettingsMenu()));
                  //     },
                  //     elevation: 0.0,
                  //     // color: Colors.white,
                  //     shape: const StadiumBorder(),
                  //     child: const Text(
                  //       'Settings',
                  //       style: TextStyle(fontSize: 24.0, color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                  // About Game Button
                  // Container(
                  //   margin: const EdgeInsets.only(top: 16.0),
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(200),
                  //       boxShadow: const [
                  //         BoxShadow(
                  //           color: Colors.black26,
                  //           blurRadius: 48.0,
                  //         )
                  //       ]),
                  //   child: MaterialButton(
                  //     onPressed: () {
                  //       Navigator.of(context).push(MaterialPageRoute(
                  //           builder: (context) => const AboutScreen()));
                  //     },
                  //     elevation: 0.0,
                  //     // color: Colors.white,
                  //     shape: const StadiumBorder(),
                  //     child: const Text(
                  //       'About',
                  //       style: TextStyle(fontSize: 24.0, color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                  // // Exit Button
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      elevation: 0.0,
                      shape: const StadiumBorder(),
                      child: const Text(
                        'Exit',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Settings Button
          // Positioned(
          //     bottom: 24.0,
          //     left: 28.0,
          //     child: IconButton(
          //         onPressed: () {
          //           Navigator.of(context).push(MaterialPageRoute(
          //               builder: (context) => const SettingsMenu()));
          //         },
          //         iconSize: 42.0,
          //         color: Colors.white,
          //         icon: const Icon(Icons.settings))),
          // // Exit Button
          // Positioned(
          //     bottom: 24.0,
          //     right: 28.0,
          //     child: IconButton(
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //         },
          //         iconSize: 42.0,
          //         color: Colors.white,
          //         icon: const Icon(Icons.close))),
        ],
      ),
    );
  }
}
