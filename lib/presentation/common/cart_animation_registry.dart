import 'package:flutter/material.dart';

class CartAnimationRegistry {
  static final GlobalKey navBarKey = GlobalKey(debugLabel: 'customer_bottom_nav');
  static const int cartIndex = 1;
  static const int itemCount = 4;

  static Rect? getCartRect() {
    final context = navBarKey.currentContext;
    if (context == null) return null;
    final render = context.findRenderObject();
    if (render is! RenderBox) return null;
    final size = render.size;
    if (size.width == 0 || size.height == 0) return null;
    final origin = render.localToGlobal(Offset.zero);
    final itemWidth = size.width / itemCount;
    final center = Offset(
      origin.dx + itemWidth * (cartIndex + 0.5),
      origin.dy + size.height * 0.35,
    );
    return Rect.fromCenter(center: center, width: 28, height: 28);
  }
}
