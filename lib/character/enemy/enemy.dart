import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_game_tutorial_3/character/player.dart';

enum EnemyState { idle, run, attack, die }

abstract class Enemy extends SpriteAnimationComponent with CollisionCallbacks {
  Enemy({
    super.size,
    super.position,
    this.speed = 125 * 8,
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

  final double speed; //Milliseconds to complete on run animation
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
      stepTime: (speed / idleSpriteSheet.columns) / 1000,
    );
    run();
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
