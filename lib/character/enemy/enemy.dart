import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../player.dart';

enum EnemyState { idle, run, attack, die }

abstract class Enemy extends SpriteAnimationComponent with CollisionCallbacks {
  Enemy({
    super.size,
    super.position,
    this.animationSpeed = 125 * 8,
    this.movementSpeed = 1,
    this.baseVelocity = 0,
    this.flying = false,
    this.running = false,
    this.hitBoxSize,
    this.hitBoxPosition,
    required this.idleSpriteSheet,
    required this.runSpriteSheet,
    required this.attackSpriteSheet,
  }) {
    basePosition = position.clone();
  }

  late final Vector2 basePosition;

  late double baseVelocity;
  final double animationSpeed;
  final double movementSpeed;
  final bool flying;
  final bool running;
  final Vector2? hitBoxSize;
  final Vector2? hitBoxPosition;

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
      stepTime: (animationSpeed / idleSpriteSheet.columns) / 1000,
    );
    if (running || flying) {
      run();
    } else {
      idle();
    }
  }

  @override
  Future<void>? onLoad() {
    add(RectangleHitbox(
      size: hitBoxSize,
      position: hitBoxPosition,
    ));
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is SwordGuy) {
      attack();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    if (running || flying) {
      if (x > (size.x * -1)) {
        x -= movementSpeed;
      } else {
        x = basePosition.x;
      }
    } else {
      final int avgFps = 1 ~/ (dt > 0 && dt.isFinite ? dt : 1.0);

      // If in visible viewport
      if (x >= (size.x * -1)) {
        x -= (baseVelocity / avgFps);
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
      )..onComplete = running || flying ? run : idle;
    }
  }
}
