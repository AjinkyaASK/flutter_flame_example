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

  late final ParallaxComponent floor;
  late final ParallaxComponent background;
  late final PlayerCharacter player;
  late final FlyingEyeEnemy flyingEyeEnemy;
  late final SkeletonEnemy skeletonEnemy;

  Vector2 viewportSize = Vector2.zero();
  double floorHeight = 0.0;

  double playerSpeed = 80;
  final double playerSizeFactor = 0.2125;
  final double enemySizeFactor = 0.2125;

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
            velocityMultiplier: Vector2(2, 0),
          ),
        ],
        size: Vector2(viewportSize.x, floorHeight),
        baseVelocity: Vector2(playerSpeed, 0),
      ),
      position: Vector2(0, viewportSize.y - floorHeight),
    );
    player = PlayerCharacter(
      speed: playerSpeed,
      size: Vector2.all(viewportSize.y * playerSizeFactor),
      position: Vector2(viewportSize.x * 0.075,
          viewportSize.y - floorHeight - (viewportSize.y * playerSizeFactor)),
      onHurt: () {
        playerSpeed = 0;
        background.parallax!.baseVelocity = Vector2(playerSpeed * 0.8, 0);
        floor.parallax!.baseVelocity = Vector2(playerSpeed, 0);
      },
      onRun: () {
        playerSpeed = 80;
        background.parallax!.baseVelocity = Vector2(playerSpeed * 0.8, 0);
        floor.parallax!.baseVelocity = Vector2(playerSpeed, 0);
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
      size: Vector2.all(viewportSize.y * enemySizeFactor),
      position: Vector2(viewportSize.x * 1.5,
          viewportSize.y - floorHeight - (viewportSize.y * enemySizeFactor)),
    );
    skeletonEnemy = await SkeletonEnemy.create(
      size: Vector2.all(viewportSize.y * enemySizeFactor),
      position: Vector2(viewportSize.x * 1,
          viewportSize.y - floorHeight - (viewportSize.y * enemySizeFactor)),
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

    return super.onLoad();
  }

  @override
  void onTap() {
    player.jump();
    super.onTap();
  }
}

enum PlayerState { idle, run, jump, attack, hurt, die }

class PlayerCharacter extends SpriteAnimationComponent with CollisionCallbacks {
  PlayerCharacter({
    super.size,
    super.position,
    this.speed = 125 * 8,
    this.jumpHeight = 80,
    this.onHurt,
    this.onRun,
    this.onJump,
    this.onAttack,
    this.onDie,
  }) {
    basePosition = position.clone();
  }

  late final Vector2 basePosition;

  late final SpriteSheet spriteSheet;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;

  final double speed; //Milliseconds to complete on run animation
  final double jumpHeight;
  final void Function()? onHurt;
  final void Function()? onRun;
  final void Function()? onJump;
  final void Function()? onAttack;
  final void Function()? onDie;

  PlayerState state = PlayerState.idle;

  Future<void> init() async {
    spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: await Flame.images.load('character/char_blue.png'),
      columns: 8,
      rows: 8,
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (state != PlayerState.hurt) {
      if (other is Enemy) {
        hurt();
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void idle() {
    state = PlayerState.idle;
    animation = idleAnimation;
  }

  void run() {
    if (onRun != null) {
      onRun!();
    }
    state = PlayerState.run;
    position = basePosition.clone();
    animation = runAnimation;
  }

  void hurt() {
    if (onHurt != null) {
      onHurt!();
    }
    state = PlayerState.hurt;
    position = basePosition.clone();
    animation = animation = spriteSheet.createAnimation(
      row: 7,
      stepTime: 0.125,
      loop: false,
    )..onComplete = run;
  }

  void jump() {
    _jumpUp();
  }

  void _jumpUp() {
    if (state != PlayerState.jump) {
      if (onJump != null) {
        onJump!();
      }
      state = PlayerState.jump;
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
    if (state != PlayerState.die) {
      if (onDie != null) {
        onDie!();
      }
      state = PlayerState.die;
      animation = spriteSheet.createAnimation(
        row: 5,
        stepTime: 0.175,
        loop: false,
      );
    }
  }
}

class FlyingEyeEnemy extends Enemy {
  FlyingEyeEnemy({
    super.size,
    super.position,
    super.speed,
    required super.idleSpriteSheet,
    required super.runSpriteSheet,
    required super.attackSpriteSheet,
  }) : super(flying: true);

  static Future<FlyingEyeEnemy> create({
    required Vector2 size,
    required Vector2 position,
    double speed = 125 * 8,
  }) async {
    final object = FlyingEyeEnemy(
      size: size,
      speed: speed,
      position: position,
      idleSpriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await Flame.images.load('character/enemy/FlyingEye/Flight.png'),
        columns: 8,
        rows: 1,
      ),
      runSpriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await Flame.images.load('character/enemy/FlyingEye/Flight.png'),
        columns: 8,
        rows: 1,
      ),
      attackSpriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await Flame.images.load('character/enemy/FlyingEye/Attack.png'),
        columns: 8,
        rows: 1,
      ),
    );
    await object.init();
    return object;
  }
}

class SkeletonEnemy extends Enemy {
  SkeletonEnemy({
    super.size,
    super.position,
    super.speed,
    required super.idleSpriteSheet,
    required super.runSpriteSheet,
    required super.attackSpriteSheet,
  }) : super(running: true);

  static Future<SkeletonEnemy> create({
    required Vector2 size,
    required Vector2 position,
    double speed = 125 * 8,
  }) async {
    final object = SkeletonEnemy(
      size: size,
      speed: speed,
      position: position,
      idleSpriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await Flame.images.load('character/enemy/Skeleton/Idle.png'),
        columns: 4,
        rows: 1,
      ),
      runSpriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await Flame.images.load('character/enemy/Skeleton/Walk.png'),
        columns: 4,
        rows: 1,
      ),
      attackSpriteSheet: SpriteSheet.fromColumnsAndRows(
        image: await Flame.images.load('character/enemy/Skeleton/Attack.png'),
        columns: 8,
        rows: 1,
      ),
    );
    await object.init();
    return object;
  }
}

enum EnemyState { idle, run, attack, die }

abstract class Enemy extends SpriteAnimationComponent with CollisionCallbacks {
  Enemy({
    super.size,
    super.position,
    this.speed = 125 * 8,
    this.flying = false,
    this.running = false,
    required this.idleSpriteSheet,
    required this.runSpriteSheet,
    required this.attackSpriteSheet,
  }) {
    basePosition = position.clone();
  }

  late final Vector2 basePosition;

  final double speed; //Milliseconds to complete on run animation
  final bool flying;
  final bool running;

  late final SpriteSheet idleSpriteSheet;
  late final SpriteSheet runSpriteSheet;
  late final SpriteSheet attackSpriteSheet;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;

  EnemyState state = EnemyState.idle;

  Future<void> init() async {
    idleAnimation = idleSpriteSheet.createAnimation(
      row: 0,
      stepTime: 0.125,
    );
    runAnimation = runSpriteSheet.createAnimation(
      row: 0,
      stepTime: (speed / idleSpriteSheet.columns) / 1000,
    );
    run();
  }

  @override
  Future<void>? onLoad() {
    add(RectangleHitbox(
      position: Vector2(size.x * 0.25, size.y * 0.25),
      size: Vector2(size.x * 0.5, size.y * 0.5),
    ));
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    attack();
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    if (running || flying) {
      if (x > (size.x * -1)) {
        x -= 1;
      } else {
        x = basePosition.x;
      }
    }
    super.update(dt);
  }

  idle() {
    state = EnemyState.idle;
    animation = idleAnimation;
  }

  run() {
    state = EnemyState.run;
    animation = runAnimation;
  }

  attack() {
    if (state != EnemyState.attack) {
      state = EnemyState.attack;
      animation = attackSpriteSheet.createAnimation(
        row: 0,
        stepTime: 0.125,
        loop: false,
      )..onComplete = run;
    }
  }
}
