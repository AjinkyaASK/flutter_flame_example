import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'character/enemy/flying_eye.dart';
import 'character/enemy/skeleton.dart';
import 'character/obstacle/obstacle.dart';
import 'character/player.dart';

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
    // debugMode = true;
  }

  late final ParallaxComponent floor;
  late final ParallaxComponent background;

  late final SwordGuy player;

  late final FlyingEyeEnemy flyingEyeEnemy;
  late final SkeletonEnemy skeletonEnemy;

  late final Obstacle stone;

  Vector2 viewportSize = Vector2.zero();
  double floorHeight = 0.0;

  double playerSpeed = 160;
  final double playerSizeFactor = 0.35;
  final double smallEnemySizeFactor = 0.45;
  final double mediumEnemySizeFactor = 0.53;
  final double largeEnemySizeFactor = 0.75;

  final double obstacleSizeFactor = 0.125;

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
        baseVelocity: Vector2(playerSpeed * 0.8, 0),
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
          ),
        ],
        size: Vector2(viewportSize.x, floorHeight),
        baseVelocity: Vector2(playerSpeed, 0),
      ),
      position: Vector2(0, viewportSize.y - floorHeight),
    );
    player = SwordGuy(
      speed: playerSpeed,
      size: Vector2.all(viewportSize.y * playerSizeFactor),
      position: Vector2(viewportSize.x * 0.075,
          viewportSize.y - floorHeight - (viewportSize.y * playerSizeFactor)),
      hitBoxSize: Vector2(viewportSize.y * playerSizeFactor * 0.3,
          viewportSize.y * playerSizeFactor * 0.5),
      hitBoxPosition: Vector2(viewportSize.y * playerSizeFactor * 0.35,
          viewportSize.y * playerSizeFactor * 0.45),
      onHurt: () {
        // playerSpeed = 0;
        // background.parallax!.baseVelocity = Vector2(playerSpeed * 0.8, 0);
        // floor.parallax!.baseVelocity = Vector2(playerSpeed, 0);
        // stone.baseVelocity = 0.0;
      },
      onRun: () {
        // playerSpeed = 160;
        // background.parallax!.baseVelocity = Vector2(playerSpeed * 0.8, 0);
        // floor.parallax!.baseVelocity = Vector2(playerSpeed, 0);
        // stone.baseVelocity = playerSpeed;
      },
      onJump: () {},
      onAttack: () {},
      onDie: () {
        playerSpeed = 0;
        background.parallax!.baseVelocity = Vector2(playerSpeed * 0.8, 0);
        floor.parallax!.baseVelocity = Vector2(playerSpeed, 0);
      },
    );
    flyingEyeEnemy = await FlyingEyeEnemy.create(
      speed: 125 * 4,
      size: Vector2.all(viewportSize.y * smallEnemySizeFactor),
      position: Vector2(
          viewportSize.x * 1,
          viewportSize.y -
              floorHeight -
              (viewportSize.y * smallEnemySizeFactor * 1.25)),
      hitBoxSize: Vector2(viewportSize.y * smallEnemySizeFactor * 0.25,
          viewportSize.y * smallEnemySizeFactor * 0.2),
      hitBoxPosition: Vector2(viewportSize.y * smallEnemySizeFactor * 0.35,
          viewportSize.y * smallEnemySizeFactor * 0.4125),
    );
    skeletonEnemy = await SkeletonEnemy.create(
      size: Vector2.all(viewportSize.y * mediumEnemySizeFactor),
      position: Vector2(
          viewportSize.x * 0.5, //1.25,
          viewportSize.y -
              floorHeight -
              (viewportSize.y * mediumEnemySizeFactor) +
              (viewportSize.y * mediumEnemySizeFactor * 0.325)),
      hitBoxSize: Vector2(viewportSize.y * mediumEnemySizeFactor * 0.2,
          viewportSize.y * mediumEnemySizeFactor * 0.3),
      hitBoxPosition: Vector2(viewportSize.y * mediumEnemySizeFactor * 0.35,
          viewportSize.y * mediumEnemySizeFactor * 0.35),
    );
    stone = Obstacle(
      image: await Flame.images.load('decorations/rock_2.png'),
      baseVelocity: playerSpeed,
      size: Vector2(viewportSize.y * obstacleSizeFactor,
          viewportSize.y * obstacleSizeFactor * 0.5),
      position: Vector2(
          viewportSize.x * 0.5,
          viewportSize.y -
              floorHeight -
              (viewportSize.y * obstacleSizeFactor * 0.5)),
      resetPosition: Vector2(
          viewportSize.x * 3.25,
          viewportSize.y -
              floorHeight -
              (viewportSize.y * obstacleSizeFactor * 0.5)),
    );
    await player.init();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    viewportSize = canvasSize.clone();
    floorHeight = viewportSize.y / 10;
    super.onGameResize(canvasSize);
  }

  @override
  Future<void>? onLoad() async {
    await initComponents();

    add(background);
    add(floor);
    add(player);
    add(flyingEyeEnemy);
    add(skeletonEnemy);
    add(stone);

    return super.onLoad();
  }

  @override
  void onTap() {
    player.jump();
    super.onTap();
  }
}
