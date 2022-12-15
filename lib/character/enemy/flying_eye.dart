import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';

import 'enemy.dart';

class FlyingEyeEnemy extends Enemy {
  FlyingEyeEnemy({
    super.size,
    super.position,
    super.animationSpeed,
    super.movementSpeed,
    super.baseVelocity,
    super.hitBoxSize,
    super.hitBoxPosition,
    required super.idleSpriteSheet,
    required super.runSpriteSheet,
    required super.attackSpriteSheet,
  }) : super(
          flying: true,
        );

  static Future<FlyingEyeEnemy> create({
    required Vector2 size,
    required Vector2 position,
    required Vector2 hitBoxSize,
    required Vector2 hitBoxPosition,
    double animationSpeed = 125 * 8,
    double movementSpeed = 1,
    double baseVelocity = 0,
  }) async {
    final object = FlyingEyeEnemy(
      size: size,
      animationSpeed: animationSpeed,
      movementSpeed: movementSpeed,
      baseVelocity: baseVelocity,
      position: position,
      hitBoxSize: hitBoxSize,
      hitBoxPosition: hitBoxPosition,
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
