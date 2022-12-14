import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

import 'enemy/enemy.dart';
import 'obstacle/obstacle.dart';

enum PlayerState { idle, run, jump, attack, hurt, die }

class SwordGuy extends SpriteAnimationComponent with CollisionCallbacks {
  SwordGuy({
    super.size,
    super.position,
    this.speed = 125 * 8,
    this.jumpHeight = 80,
    this.hitBoxSize,
    this.hitBoxPosition,
    this.onHurt,
    this.onRun,
    this.onJump,
    this.onAttack,
    this.onDie,
  }) {
    basePosition = position.clone();
  }

  late final Vector2 basePosition;
  final Vector2? hitBoxSize;
  final Vector2? hitBoxPosition;

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
      position: hitBoxPosition, //Vector2(size.x * 0.35, size.y * 0.4),
      size: hitBoxSize, //Vector2(size.x * 0.3, size.y * 0.5),
    ));
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (state != PlayerState.hurt) {
      if (other is Enemy || other is Obstacle) {
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
      stepTime: 0.25,
      loop: false,
      from: 0,
      to: 6,
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
