import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';

import 'enemy.dart';

class SkeletonEnemy extends Enemy {
  SkeletonEnemy({
    super.size,
    super.position,
    super.speed,
    super.hitBoxSize,
    super.hitBoxPosition,
    required super.idleSpriteSheet,
    required super.runSpriteSheet,
    required super.attackSpriteSheet,
  }) : super(
        // running: true,
        );

  static Future<SkeletonEnemy> create({
    required Vector2 size,
    required Vector2 position,
    required Vector2 hitBoxSize,
    required Vector2 hitBoxPosition,
    double speed = 125 * 8,
  }) async {
    final object = SkeletonEnemy(
      size: size,
      speed: speed,
      position: position,
      hitBoxSize: hitBoxSize,
      hitBoxPosition: hitBoxPosition,
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
