import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: WoodRunner(),
    );
  }
}

class WoodRunner extends FlameGame with TapDetector, HasCollisionDetection {
  WoodRunner() {
    debugMode = true;
  }

  late final Component floor;
  late final Component background;
  late final PlayerCharacter player;

  Future<void> initComponents() async {
    background = ParallaxComponent(
      parallax: Parallax(
        [
          ParallaxLayer(
            ParallaxImage(
              await Flame.images.load('background/background_layer_1.png'),
              repeat: ImageRepeat.repeatX,
              fill: LayerFill.height,
            ),
            velocityMultiplier: Vector2(1, 0),
          ),
          ParallaxLayer(
            ParallaxImage(
              await Flame.images.load('background/background_layer_2.png'),
              repeat: ImageRepeat.repeatX,
              fill: LayerFill.height,
            ),
            velocityMultiplier: Vector2(1.5, 0),
          ),
          ParallaxLayer(
            ParallaxImage(
              await Flame.images.load('background/background_layer_3.png'),
              repeat: ImageRepeat.repeatX,
              fill: LayerFill.height,
            ),
            velocityMultiplier: Vector2(2, 0),
          ),
        ],
        baseVelocity: Vector2(60, 0),
      ),
    );
    floor = ParallaxComponent(
      parallax: Parallax(
        [
          ParallaxLayer(
            ParallaxImage(
              await Flame.images.load('floor_tile.png'),
              repeat: ImageRepeat.repeatX,
              // fill: LayerFill.height,
            ),
            velocityMultiplier: Vector2(2, 0),
          ),
        ],
        size: Vector2(500, 100),
        baseVelocity: Vector2(80, 0),
      ),
      position: Vector2(0, 820),
    );
    player = PlayerCharacter(
      size: Vector2(200, 200),
      position: Vector2(60, 620),
    );
    await player.init();
  }

  @override
  Future<void>? onLoad() async {
    await initComponents();

    add(background);
    add(floor);
    add(player);

    return super.onLoad();
  }

  @override
  void onTap() {
    player.jump();
    super.onTap();
  }
}

class PlayerCharacter extends SpriteAnimationComponent with CollisionCallbacks {
  PlayerCharacter({
    super.size,
    super.position,
  }) {
    basePosition = position.clone();
  }

  late final Vector2 basePosition;

  late final SpriteSheet spriteSheet;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation attackAnimation;

  final double jumpHeight = 80;

  Future<void> init() async {
    spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: await Flame.images.load('character/char_blue.png'),
      columns: 8,
      rows: 7,
    );

    idleAnimation = spriteSheet.createAnimation(
      row: 0,
      from: 0,
      to: 5,
      stepTime: 0.175,
    );

    runAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: 0.125,
    );

    run();
  }

  @override
  Future<void>? onLoad() {
    add(RectangleHitbox(
      position: Vector2(size.x * 0.35, size.y * 0.4),
      size: Vector2(size.x * 0.3, size.y * 0.5),
    ));
    return super.onLoad();
  }

  void idle() {
    animation = idleAnimation;
  }

  void run() {
    position = basePosition.clone();
    animation = runAnimation;
  }

  void jump() {
    _jumpUp();
  }

  void _jumpUp() {
    animation = spriteSheet.createAnimation(
      row: 3,
      stepTime: 0.125,
      loop: false,
    )
      ..onFrame = (frame) {
        final newY = basePosition.y - ((jumpHeight / 8) * (frame + 1));
        y = newY >= (basePosition.y - jumpHeight) ? newY : basePosition.y;
        // log('Jumping up - Height: $y');
      }
      ..onComplete = _jumpDown;
  }

  void _jumpDown() {
    animation = spriteSheet.createAnimation(
      row: 4,
      stepTime: 0.125,
      loop: false,
    )
      ..onFrame = (frame) {
        final newY =
            (basePosition.y - jumpHeight) + ((jumpHeight / 8) * (frame + 1));
        y = newY <= basePosition.y ? newY : basePosition.y;
        // log('Jumping down - Height: $y');
      }
      ..onComplete = run;
  }

  void die() {
    animation = spriteSheet.createAnimation(
      row: 5,
      stepTime: 0.175,
      loop: false,
    );
  }
}
