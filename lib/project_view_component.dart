// 캐릭터, 배경, 대화창을 담는 용도의 컴포넌트
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:jenny/jenny.dart';
import 'package:kojaem_novel_game_prototype/constants/customColor.dart';
import 'package:kojaem_novel_game_prototype/dialogue_overlay.dart';
import 'package:kojaem_novel_game_prototype/main_dialogue_text_component.dart';
import 'package:kojaem_novel_game_prototype/route.dart';
import 'package:kojaem_novel_game_prototype/rrect_dialogue_overlay.dart';

class ProjectViewComponent extends PositionComponent
    with DialogueView, HasGameRef<RouterGame> {
  ProjectViewComponent(this.yarnProject);

  final YarnProject yarnProject;
  late DialogueTextComponent mainDialogueTextComponent =
      DialogueTextComponent();
  late DialogueTextComponent fastCompletedMainDialogueTextComponent =
      DialogueTextComponent();
  late DialogueTextComponent nameDialogueTextComponent =
      DialogueTextComponent();
  late DialogueOverlay mainDialogueOverlay = DialogueOverlay();
  late RRectDialogueOverlay nameDialogueOverlay = RRectDialogueOverlay();
  final background = SpriteComponent();
  final leftPerson = SpriteComponent();
  final rightPerson = SpriteComponent();
  late ButtonComponent forwardButtonComponent =
      ButtonComponent(); // 대화 넘기는 감지 버튼
  Completer<void> _forwardCompleter = Completer();
  Completer<int> _choiceCompleter = Completer<int>();
  bool isNameComponentRendered = false;
  bool isCompletedMainDialogueRendered = false;

  List<ButtonComponent> optionsList = [];

  final textPaint = TextPaint(
      style: const TextStyle(
    color: CustomColor.brightGray,
    fontSize: 20,
    height: 1.4,
  ));

  @override
  FutureOr<void> onLoad() {
    background
      ..sprite = Sprite(gameRef.images.fromCache('transparent.png'))
      ..size = gameRef.size
      ..opacity = 0
      ..add(OpacityEffect.fadeIn(EffectController(duration: 0.25)));

    leftPerson
      ..sprite = Sprite(gameRef.images.fromCache('transparent.png'))
      ..size = Vector2(400, 400)
      ..position = Vector2(gameRef.size.x * 0.01, gameRef.size.y * 0.1)
      ..opacity = 0
      ..add(
          OpacityEffect.fadeIn(EffectController(duration: 0.5, startDelay: 1)));

    rightPerson
      ..sprite = Sprite(gameRef.images.fromCache('transparent.png'))
      ..size = Vector2(400, 400)
      ..position = Vector2(gameRef.size.x * 0.99, gameRef.size.y * 0.1)
      ..opacity = 0
      ..add(OpacityEffect.fadeIn(
          EffectController(duration: 0.5, startDelay: 1.5)))
      ..anchor = Anchor.topRight;
    // ..add(OpacityEffect.fadeOut(
    //     EffectController(duration: 0.5, startDelay: 1)));

    forwardButtonComponent = ButtonComponent(
        button: PositionComponent(),
        size: gameRef.size,
        onPressed: () {
          if ((mainDialogueTextComponent.checkDialogueFinished() ||
                  isCompletedMainDialogueRendered) &&
              !_forwardCompleter.isCompleted) {
            _forwardCompleter.complete();
          } else {
            if (!isCompletedMainDialogueRendered) {
              fastCompletedMainDialogueTextComponent = DialogueTextComponent(
                size: Vector2(gameRef.size.x * .9, gameRef.size.y * .3),
                textRenderer: textPaint,
                position: Vector2(
                  gameRef.size.x * .05,
                  gameRef.size.y * .65,
                ),
                boxConfig: TextBoxConfig(
                  margins: const EdgeInsets.all(8.0),
                  growingBox: false,
                ),
              )..text = mainDialogueTextComponent.text;
              add(fastCompletedMainDialogueTextComponent);
              isCompletedMainDialogueRendered = true;
              mainDialogueTextComponent.removeFromParent();
            }
          }
        });

    mainDialogueOverlay = DialogueOverlay(
      size: Vector2(gameRef.size.x * .9, gameRef.size.y * .3),
      position: Vector2(
        gameRef.size.x * .05,
        gameRef.size.y * .65,
      ),
    );

    nameDialogueTextComponent = DialogueTextComponent(
      size: Vector2(200, 40),
      align: Anchor.center,
      textRenderer: textPaint.copyWith(
        (p0) => p0.merge(
          const TextStyle(fontSize: 20),
        ),
      ),
      position: Vector2(
        gameRef.size.x * .05,
        gameRef.size.y * .65 - 40,
      ),
      boxConfig: TextBoxConfig(
        maxWidth: gameRef.size.x * .9,
        margins: const EdgeInsets.all(8.0),
        growingBox: false,
        // timePerChar: 0.05,
      ),
    );

    nameDialogueOverlay = RRectDialogueOverlay(
      size: Vector2(200, 40),
      position: Vector2(
        gameRef.size.x * .05,
        gameRef.size.y * .65 - 40,
      ),
    );

    addAll([
      background,
      forwardButtonComponent,
      leftPerson,
      rightPerson,
      // mainDialogueTextComponent,
      mainDialogueOverlay,
      nameDialogueTextComponent,
      nameDialogueOverlay,
    ]);
    return super.onLoad();
  }

  @override
  FutureOr<bool> onLineStart(DialogueLine line) async {
    fastCompletedMainDialogueTextComponent.removeFromParent();
    isCompletedMainDialogueRendered = false;
    add(forwardButtonComponent);
    _forwardCompleter = Completer();
    await _advance(line);
    return super.onLineStart(line);
  }

  @override
  FutureOr<void> onLineFinish(DialogueLine line) async {
    mainDialogueTextComponent.removeFromParent();
    // fastCompletedMainDialogueTextComponent.removeFromParent();
    isCompletedMainDialogueRendered = false;
    forwardButtonComponent.removeFromParent();
    return super.onLineFinish(line);
  }

  @override
  FutureOr<int?> onChoiceStart(DialogueChoice choice) async {
    _choiceCompleter = Completer<int>();
    forwardButtonComponent.removeFromParent();
    mainDialogueOverlay.removeFromParent();
    nameDialogueOverlay.removeFromParent();
    for (int i = 0; i < choice.options.length; i++) {
      optionsList.add(ButtonComponent(
          position: Vector2(
            gameRef.size.x * .05 + 8,
            gameRef.size.y * .1 + i * 50 + 8,
          ), // position 에 8을 더하는 이유 : `mainDialogueTextComponent` 의 margin 값
          button: TextComponent(
            text: choice.options[i].text,
            textRenderer: textPaint.copyWith(
              (p0) => p0.merge(
                TextStyle(
                  backgroundColor: CustomColor.black.withAlpha(150),
                ),
              ),
            ),
          ),
          onPressed: () {
            if (!_choiceCompleter.isCompleted) {
              _choiceCompleter.complete(i);
            }
          }));
    }
    addAll(optionsList);
    await _getChoice(choice);

    return _choiceCompleter.future;
  }

  @override
  FutureOr<void> onChoiceFinish(DialogueOption option) {
    removeAll(optionsList);
    optionsList = [];
    addAll([
      // forwardButtonComponent,
      // mainDialogueTextComponent,
      mainDialogueOverlay,
      nameDialogueOverlay,
      nameDialogueTextComponent,
    ]);
  }

  @override
  FutureOr<void> onNodeStart(Node node) async {
    if (!forwardButtonComponent.isMounted) {
      add(forwardButtonComponent);
    }
    add(mainDialogueOverlay); // 노드 변경되고 mainDialogueOverlay 추가
    return super.onNodeStart(node);
  }

  @override
  FutureOr<void> onNodeFinish(Node node) {
    nameDialogueTextComponent.removeFromParent();
    nameDialogueOverlay.removeFromParent();
    mainDialogueTextComponent.removeFromParent();
    mainDialogueOverlay.removeFromParent();
    fastCompletedMainDialogueTextComponent.removeFromParent();
    forwardButtonComponent.removeFromParent();
    // 해당 대화 노드가 끝나고 처리하는 부분
    // this.removeFromParent();
  }

  Future<void> _getChoice(DialogueChoice choice) async {
    // return _forwardCompleter.future;
  }

  Future<void> _advance(DialogueLine line) async {
    var characterName = line.character?.name;
    var lineText = line.text;
    // mainDialogueTextComponent.text = lineText;
    nameDialogueTextComponent.text = characterName ?? '';

    if (nameDialogueTextComponent.text == '') {
      nameDialogueTextComponent.removeFromParent();
      nameDialogueOverlay.removeFromParent();
      isNameComponentRendered = false;
    } else {
      if (!isNameComponentRendered) {
        addAll([nameDialogueOverlay, nameDialogueTextComponent]);
        isNameComponentRendered = true;
      }
    }

    mainDialogueTextComponent = DialogueTextComponent(
      size: Vector2(gameRef.size.x * .9, gameRef.size.y * .3),
      textRenderer: textPaint,
      position: Vector2(
        gameRef.size.x * .05,
        gameRef.size.y * .65,
      ),
      boxConfig: TextBoxConfig(
        margins: const EdgeInsets.all(8.0),
        growingBox: false,
        timePerChar: 0.05,
      ),
    )..text = lineText;

    mainDialogueTextComponent = DialogueTextComponent(
      size: Vector2(gameRef.size.x * .9, gameRef.size.y * .3),
      textRenderer: textPaint,
      position: Vector2(
        gameRef.size.x * .05,
        gameRef.size.y * .65,
      ),
      boxConfig: TextBoxConfig(
        margins: const EdgeInsets.all(8.0),
        growingBox: false,
        timePerChar: 0.05,
      ),
    )..text = lineText;

    add(mainDialogueTextComponent);

    return _forwardCompleter.future;
  }
}
