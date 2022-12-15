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
import 'screens/game_over_menu.dart';
import 'screens/main_menu.dart';
import 'screens/pause_menu.dart';
import 'widgets/life_indicator.dart';
import 'widgets/pause_button.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainMenu(),
  ));
}

void exitGame(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainMenu()), (_) => false);
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget<WoodRunner>(
      game: WoodRunner(),
      overlayBuilderMap: {
        'pause_menu': (context, game) {
          return PauseMenu(
            onResume: game.resumeGame,
            onRestart: game.restartGame,
            onExit: () => exitGame(context),
          );
        },
        'game_over_menu': (context, game) {
          return GameOverMenu(
            onRestart: game.restartGame,
            onExit: () => exitGame(context),
          );
        },
        'pause_button': (context, game) {
          return PauseButton(
            onTap: game.pauseGame,
          );
        },
        'hud': (context, game) {
          return Align(
              alignment: Alignment.topRight,
              child: LifeIndicator(remainingLifesNotifier: game.life));
        }
      },
    );
  }
}

class Life {
  Life({required this.remainingLifes, required this.totalLifes});

  final int remainingLifes;
  final int totalLifes;
}

class WoodRunner extends FlameGame with TapDetector, HasCollisionDetection {
  WoodRunner() {
    debugMode = true;
  }

  late final ParallaxComponent floor;
  late final ParallaxComponent background;

  late final SwordGuy player;

  late final FlyingEyeEnemy flyingEyeEnemy;
  late final SkeletonEnemy skeletonEnemy;

  late final Obstacle stone;

  Vector2 viewportSize = Vector2.zero();
  double floorHeight = 0.0;

  double playerSpeed = 120;
  final double playerSizeFactor = 0.35;
  final double smallEnemySizeFactor = 0.45;
  final double mediumEnemySizeFactor = 0.53;
  final double largeEnemySizeFactor = 0.75;

  final double obstacleSizeFactor = 0.125;

  final ValueNotifier<Life> life =
      ValueNotifier(Life(remainingLifes: totalLifes, totalLifes: totalLifes));

  static const List<String> overlayIdentifiers = [
    'pause_button',
    'pause_menu',
    'hud',
    'game_over_menu'
  ];

  final pauseButtonIdentifier = overlayIdentifiers[0];
  final pauseMenuIdentifier = overlayIdentifiers[1];
  final hudIdentifier = overlayIdentifiers[2];
  final gameOverMenuIdentifier = overlayIdentifiers[3];

  int score = 0;
  static const int totalLifes = 3;

  void onEnemyHit() {
    if (life.value.remainingLifes > 0) {
      life.value = Life(
          remainingLifes: life.value.remainingLifes - 1,
          totalLifes: life.value.totalLifes);
    } else {
      onGameOver();
    }
  }

  void resumeGame() {
    if (paused) {
      overlays.remove(pauseMenuIdentifier);
      overlays.remove(gameOverMenuIdentifier);
      resumeEngine();
    }
  }

  void pauseGame() {
    if (!paused) {
      pauseEngine();
      overlays.add(pauseMenuIdentifier);
    }
  }

  void onGameOver() {
    pauseEngine();
    overlays.add(gameOverMenuIdentifier);
  }

  void restartGame() {
    score = 0;
    life.value = Life(remainingLifes: totalLifes, totalLifes: totalLifes);
    resumeGame();
  }

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
      jumpHeight: 120.0,
      size: Vector2.all(viewportSize.y * playerSizeFactor),
      position: Vector2(viewportSize.x * 0.075,
          viewportSize.y - floorHeight - (viewportSize.y * playerSizeFactor)),
      hitBoxSize: Vector2(viewportSize.y * playerSizeFactor * 0.3,
          viewportSize.y * playerSizeFactor * 0.5),
      hitBoxPosition: Vector2(viewportSize.y * playerSizeFactor * 0.35,
          viewportSize.y * playerSizeFactor * 0.45),
      onHurt: () {
        onEnemyHit();
      },
      onRun: () {},
      onJump: () {},
      onAttack: () {},
      onDie: () {
        playerSpeed = 0;
        background.parallax!.baseVelocity = Vector2(playerSpeed * 0.8, 0);
        floor.parallax!.baseVelocity = Vector2(playerSpeed, 0);
      },
    );
    flyingEyeEnemy = await FlyingEyeEnemy.create(
      animationSpeed: 125 * 4,
      movementSpeed: 3,
      baseVelocity: playerSpeed,
      size: Vector2.all(viewportSize.y * smallEnemySizeFactor),
      position: Vector2(
          viewportSize.x * 1.5,
          viewportSize.y -
              floorHeight -
              (viewportSize.y * smallEnemySizeFactor * 1.25)),
      hitBoxSize: Vector2(viewportSize.y * smallEnemySizeFactor * 0.25,
          viewportSize.y * smallEnemySizeFactor * 0.2),
      hitBoxPosition: Vector2(viewportSize.y * smallEnemySizeFactor * 0.2,
          viewportSize.y * smallEnemySizeFactor * 0.4125),
    );
    skeletonEnemy = await SkeletonEnemy.create(
      size: Vector2.all(viewportSize.y * mediumEnemySizeFactor),
      baseVelocity: playerSpeed,
      position: Vector2(
          viewportSize.x * 1.25,
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
          viewportSize.x * 0.85,
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
    overlays.add(pauseButtonIdentifier);
    overlays.add(hudIdentifier);

    return super.onLoad();
  }

  @override
  void onTap() {
    player.jump();
    super.onTap();
  }
}
