import 'package:flutter/material.dart';

class PauseButton extends StatelessWidget {
  const PauseButton({Key? key, this.onTap}) : super(key: key);

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Material(
            color: Colors.black26,
            shape: const CircleBorder(),
            child: IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.pause),
                color: Colors.white,
                padding: EdgeInsets.zero,
                iconSize: 36.0)));
  }
}
