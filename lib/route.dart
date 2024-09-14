import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/rendering.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/rendering.dart';
import 'package:kojaem_novel_game_prototype/constants/customColor.dart';
import 'package:kojaem_novel_game_prototype/main.dart';
import 'package:kojaem_novel_game_prototype/splash_screen_page.dart';
import 'package:kojaem_novel_game_prototype/start_page.dart';

class RouterGame extends FlameGame {
  late final RouterComponent router;
  bool playBgm = true;
  bool playDialogueSounds = true;

  @override
  Future<void> onLoad() async {
    // await images.loadAllImages();

    add(
      router = RouterComponent(
        routes: {
          'splash': Route(SplashScreenPage.new),
          'home': Route(StartPage.new),
          'level1': Route(JennyGame.new),
          'level2': Route(Level2Page.new),
          'pause': PauseRoute(),
        },
        initialRoute: 'splash',
      ),
    );
  }
}

class Background extends Component {
  Background(this.color);
  final Color color;

  @override
  void render(Canvas canvas) {
    canvas.drawColor(color, BlendMode.srcATop);
  }
}

class RoundedButton extends PositionComponent with TapCallbacks {
  RoundedButton({
    required this.text,
    required this.action,
    required Color color,
    required Color borderColor,
    super.position,
    super.anchor = Anchor.center,
  }) : _textDrawable = TextPaint(
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w800,
          ),
        ).toTextPainter(text) {
    size = Vector2(150, 40);
    _textOffset = Offset(
      (size.x - _textDrawable.width) / 2,
      (size.y - _textDrawable.height) / 2,
    );
    _rrect = RRect.fromLTRBR(0, 0, size.x, size.y, Radius.circular(size.y / 2));
    _bgPaint = Paint()..color = color;
    _borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = borderColor;
  }

  final String text;
  final void Function() action;
  final TextPainter _textDrawable;
  late final Offset _textOffset;
  late final RRect _rrect;
  late final Paint _borderPaint;
  late final Paint _bgPaint;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_rrect, _bgPaint);
    canvas.drawRRect(_rrect, _borderPaint);
    _textDrawable.paint(canvas, _textOffset);
  }

  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(1.05);
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    action();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}

abstract class SimpleButton extends PositionComponent with TapCallbacks {
  SimpleButton(this._iconPath, {super.position, double? strokeWidth})
      : _iconPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xffaaaaaa)
          ..strokeWidth = strokeWidth ?? 7,
        super(size: Vector2.all(40));

  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0x66ffffff);

  final Paint _iconPaint; // 생성자에서 초기화하므로 여기서는 초기화하지 않음
  final Path _iconPath;

  void action();

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      _borderPaint,
    );
    canvas.drawPath(_iconPath, _iconPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _iconPaint.color = const Color(0xffffffff);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _iconPaint.color = const Color(0xffaaaaaa);
    action();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _iconPaint.color = const Color(0xffaaaaaa);
  }
}

class BackRouteButton extends SimpleButton with HasGameReference<RouterGame> {
  // position 값을 props로 받을 수 있도록 생성자에 position 파라미터 추가
  BackRouteButton({Vector2? position})
      : super(
          Path()
            ..moveTo(22, 8)
            ..lineTo(10, 20)
            ..lineTo(22, 32)
            ..moveTo(12, 20)
            ..lineTo(34, 20),
          // 전달된 position 값이 null 이면 기본값 Vector2.all(10) 사용
          position: position ?? Vector2.all(10),
        );

  @override
  void action() {
    FlameAudio.bgm.stop();
    game.router.pop();
  }
}

class BgmToggleButton extends SimpleButton with HasGameReference<RouterGame> {
  // position 값을 props로 받을 수 있도록 생성자에 position 파라미터 추가
  BgmToggleButton({Vector2? position})
      : super(
          _createMusicIconPath(),
          // 전달된 position 값이 null 이면 기본값 Vector2(120, 10) 사용
          position: position ?? Vector2(120, 10),
          strokeWidth: 3,
        );

  bool get isBgmOn => game.playBgm;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(40, 40); // 버튼의 크기 설정
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!isBgmOn) {
      final mutePath = Path()
        ..moveTo(5, 5)
        ..lineTo(35, 35);
      final mutePaint = Paint()
        ..color = CustomColor.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawPath(mutePath, mutePaint);
    }
  }

  @override
  void action() {
    game.playBgm = !game.playBgm;
    if (game.playBgm) {
      _playBgm();
    } else {
      _stopBgm();
    }
  }

  void _playBgm() {
    game.playBgm = true;
  }

  void _stopBgm() {
    game.playBgm = false;
  }

  // 음악 아이콘을 그리는 Path를 생성하는 메서드
  static Path _createMusicIconPath() {
    final path = Path();

    path.addOval(Rect.fromCircle(center: const Offset(12, 28), radius: 6));
    path.addOval(Rect.fromCircle(center: const Offset(28, 28), radius: 6));
    path.moveTo(18, 28);
    path.lineTo(18, 10);
    path.moveTo(34, 28);
    path.lineTo(34, 10);
    path.moveTo(18, 10);
    path.lineTo(34, 10);

    return path;
  }
}

class PauseButton extends SimpleButton with HasGameReference<RouterGame> {
  // position 값을 props로 받을 수 있도록 생성자에 position 파라미터 추가
  PauseButton({Vector2? position})
      : super(
          Path()
            ..moveTo(14, 10)
            ..lineTo(14, 30)
            ..moveTo(26, 10)
            ..lineTo(26, 30),
          // 전달된 position 값이 null 이면 기본값 Vector2(60, 10) 사용
          position: position ?? Vector2(60, 10),
        );

  @override
  void action() => game.router.pushNamed('pause');
}

class Level1Page extends Component {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      Background(const Color(0xbb2a074f)),
      BackRouteButton(),
      PauseButton(),
      Planet(
        radius: 25,
        color: const Color(0xfffff188),
        position: game.size / 2,
        children: [
          Orbit(
            radius: 110,
            revolutionPeriod: 6,
            planet: Planet(
              radius: 10,
              color: const Color(0xff54d7b1),
              children: [
                Orbit(
                  radius: 25,
                  revolutionPeriod: 5,
                  planet: Planet(radius: 3, color: const Color(0xFFcccccc)),
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }
}

// Todo 삭제 or 다른페이지로 변경
class Level2Page extends Component {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      Background(const Color(0xff052b44)),
      BackRouteButton(position: Vector2(20, 10)),
      PauseButton(position: Vector2(70, 10)),
      BgmToggleButton(position: Vector2(120, 10)),
      Planet(
        radius: 30,
        color: const Color(0xFFFFFFff),
        position: game.size / 2,
        children: [
          Orbit(
            radius: 60,
            revolutionPeriod: 5,
            planet: Planet(radius: 10, color: const Color(0xffc9ce0d)),
          ),
          Orbit(
            radius: 110,
            revolutionPeriod: 10,
            planet: Planet(
              radius: 14,
              color: const Color(0xfff32727),
              children: [
                Orbit(
                  radius: 26,
                  revolutionPeriod: 3,
                  planet: Planet(radius: 5, color: const Color(0xffffdb00)),
                ),
                Orbit(
                  radius: 35,
                  revolutionPeriod: 4,
                  planet: Planet(radius: 3, color: const Color(0xffdc00ff)),
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }
}

class Planet extends PositionComponent {
  Planet({
    required this.radius,
    required this.color,
    super.position,
    super.children,
  }) : _paint = Paint()..color = color;

  final double radius;
  final Color color;
  final Paint _paint;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _paint);
  }
}

class Orbit extends PositionComponent {
  Orbit({
    required this.radius,
    required this.planet,
    required this.revolutionPeriod,
    double initialAngle = 0,
  })  : _paint = Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x888888aa),
        _angle = initialAngle {
    add(planet);
  }

  final double radius;
  final double revolutionPeriod;
  final Planet planet;
  final Paint _paint;
  double _angle;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _paint);
  }

  @override
  void update(double dt) {
    _angle += dt / revolutionPeriod * tau;
    planet.position = Vector2(radius, 0)..rotate(_angle);
  }
}

class PauseRoute extends Route {
  PauseRoute() : super(PausePage.new, transparent: true);

  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime()
      ..addRenderEffect(
        PaintDecorator.grayscale(opacity: 0.5)..addBlur(3.0),
      );
  }

  @override
  void onPop(Route nextRoute) {
    nextRoute
      ..resumeTime()
      ..removeRenderEffect();
  }
}

class PausePage extends Component
    with TapCallbacks, HasGameReference<RouterGame> {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      TextComponent(
        text: 'PAUSED',
        position: game.canvasSize / 2,
        anchor: Anchor.center,
        children: [
          ScaleEffect.to(
            Vector2.all(1.1),
            EffectController(
              duration: 0.3,
              alternate: true,
              infinite: true,
            ),
          ),
        ],
      ),
    ]);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapUp(TapUpEvent event) => game.router.pop();
}
