import 'package:flutter/material.dart';

import '../main.dart';

class LifeIndicator extends StatelessWidget {
  const LifeIndicator({Key? key, required this.remainingLifesNotifier})
      : super(key: key);

  final ValueNotifier<Life> remainingLifesNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ValueListenableBuilder<Life>(
          valueListenable: remainingLifesNotifier,
          builder: (context, value, _) {
            return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                        value.totalLifes - value.remainingLifes,
                        (index) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                                'assets/images/extra/dead_heart.png',
                                width: 32.0,
                                height: 32.0))) +
                    List.generate(
                        value.remainingLifes,
                        (index) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset('assets/images/extra/heart.png',
                                width: 32.0, height: 32.0))));
          }),
    );
  }
}
