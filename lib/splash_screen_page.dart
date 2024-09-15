import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:kojaem_novel_game_prototype/constants/customColor.dart';
import 'package:kojaem_novel_game_prototype/route.dart';

class SplashScreenPage extends Component
    with TapCallbacks, HasGameReference<RouterGame> {
  @override
  Future<void> onLoad() async {
    addAll([
      Background(const Color(0xff282828)),
      TextBoxComponent(
        text: '[3초 뒤 이동]',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: CustomColor.brightGray,
            fontSize: 16,
            fontFamily: 'GmarketSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        align: Anchor.center,
        size: game.canvasSize,
      ),
    ]);

    // 3초 후에 home 페이지로 이동
    Future.delayed(const Duration(seconds: 3), () {
      game.router.pushNamed('home');
    });
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;
}
