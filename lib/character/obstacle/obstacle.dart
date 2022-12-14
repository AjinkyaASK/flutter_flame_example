import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Obstacle extends SpriteComponent with CollisionCallbacks {
  Obstacle({
    super.size,
    super.position,
    this.resetPosition,
    this.baseVelocity = 0,
    this.hitBoxSize,
    this.hitBoxPosition,
    required this.image,
  }) : super.fromImage(image) {
    basePosition = position.clone();
  }

  late double baseVelocity;
  late final Vector2 basePosition;
  late final Vector2? resetPosition;

  final Vector2? hitBoxSize;
  final Vector2? hitBoxPosition;
  late final Image image;

  @override
  Future<void>? onLoad() {
    add(RectangleHitbox(
      size: hitBoxSize,
      position: hitBoxPosition,
    ));
    return super.onLoad();
  }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   super.onCollision(intersectionPoints, other);
  // }

  @override
  void update(double dt) {
    final int avgFps = 1 ~/ (dt > 0 && dt.isFinite ? dt : 1.0);

    // If in visible viewport
    if (x >= (size.x * -1)) {
      x -= (baseVelocity / avgFps);
    } else {
      x = resetPosition?.x ?? basePosition.x;
    }
    super.update(dt);
  }
}
