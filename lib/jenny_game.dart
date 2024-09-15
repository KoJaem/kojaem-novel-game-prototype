import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jenny/jenny.dart';
import 'package:kojaem_novel_game_prototype/project_view_component.dart';
import 'package:kojaem_novel_game_prototype/route.dart';

import 'constants/customColor.dart';

class JennyGame extends Component with HasGameRef<RouterGame>, TapCallbacks {
  YarnProject yarnProject = YarnProject();
  var sound;

  // * 웹 배포시 주석 해제
  // JennyGame({super.camera});

  @override
  FutureOr<void> onLoad() async {
    await game.images.loadAllImages();

    // if (game.playBgm) {
    //   FlameAudio.bgm.play('HYP - Picnic.mp3');
    // }

    String startDialogueData =
        await rootBundle.loadString('assets/yarn/start.yarn');

    String consultationData =
        await rootBundle.loadString('assets/yarn/consultation.yarn');

    ProjectViewComponent projectViewComponent =
        ProjectViewComponent(yarnProject);

    var dialogueRunner = DialogueRunner(
        yarnProject: yarnProject, dialogueViews: [projectViewComponent]);

    void imageChangeWithAnimation(String position, String url) async {
      switch (position) {
        case 'right':
          await projectViewComponent.rightPerson
              .add(OpacityEffect.fadeOut(EffectController(duration: 0.3)));
          Future.delayed(const Duration(milliseconds: 600), () {
            projectViewComponent.rightPerson.sprite =
                Sprite(game.images.fromCache(url));
            projectViewComponent.rightPerson
                .add(OpacityEffect.fadeIn(EffectController(duration: 0.3)));
          });
          break;
        case 'left':
          await projectViewComponent.leftPerson
              .add(OpacityEffect.fadeOut(EffectController(duration: 0.3)));
          Future.delayed(const Duration(milliseconds: 600), () {
            projectViewComponent.leftPerson.sprite =
                Sprite(game.images.fromCache(url));
            projectViewComponent.leftPerson
                .add(OpacityEffect.fadeIn(EffectController(duration: 0.3)));
          });
          break;
        case 'background':
          await projectViewComponent.background
              .add(OpacityEffect.fadeOut(EffectController(duration: 0.3)));
          Future.delayed(const Duration(milliseconds: 600), () {
            projectViewComponent.background.sprite =
                Sprite(game.images.fromCache(url));
            projectViewComponent.background
                .add(OpacityEffect.fadeIn(EffectController(duration: 0.3)));
          });
        default:
          break;
      }
    }

    void imageChange(String position, String url) async {
      switch (position) {
        case 'right':
          projectViewComponent.rightPerson.sprite =
              Sprite(game.images.fromCache(url));
          break;
        case 'left':
          projectViewComponent.leftPerson.sprite =
              Sprite(game.images.fromCache(url));
          break;
        case 'background':
          projectViewComponent.background.sprite =
              Sprite(game.images.fromCache(url));
        default:
          break;
      }
    }

    void removeText() async {
      projectViewComponent.fastCompletedMainDialogueTextComponent
          .removeFromParent();
      projectViewComponent.nameDialogueTextComponent.removeFromParent();
    }

    void removeTextBoxWithAnimation() async {
      projectViewComponent.fastCompletedMainDialogueTextComponent
          .removeFromParent();
      projectViewComponent.nameDialogueTextComponent.removeFromParent();

      await projectViewComponent.mainDialogueOverlay
          .add(OpacityEffect.fadeOut(EffectController(duration: 0.3)));
    }

    void createTextBox() async {
      await projectViewComponent.mainDialogueOverlay
          .add(OpacityEffect.fadeIn(EffectController(duration: 0.3)));
    }

    void changeDialogueColor(String target, String colorKey) {
      Color color = CustomColor.getColor(colorKey);
      switch (target) {
        case 'name':
          projectViewComponent.nameDialogueOverlay.bgColor = color;
          break;
        case 'conversation':
          projectViewComponent.mainDialogueOverlay.bgColor = color;
        case 'all':
        default:
          projectViewComponent.nameDialogueOverlay.bgColor = color;
          projectViewComponent.mainDialogueOverlay.bgColor = color;
          break;
      }
    }

    void startSound(String url) async {
      // 설정에서 volume 설정하는것도 좋을 것 같음
      if (sound != null) {
        await sound.stop();
      }

      sound = await FlameAudio.play(
        url,
        volume: 1,
      );
    }

    yarnProject
      ..commands
          .addCommand2('change_image_with_animation', imageChangeWithAnimation)
      ..commands.addCommand2('change_image', imageChange)
      ..commands.addCommand2('change_dialogue_color', changeDialogueColor)
      ..commands.addCommand0('create_textbox', createTextBox)
      ..commands.addCommand0('remove_text', removeText)
      ..commands.addCommand0(
          'remove_textbox_with_animation', removeTextBoxWithAnimation)
      ..commands.addCommand1('start_sound', startSound)
      ..parse(startDialogueData)
      ..parse(consultationData);

    dialogueRunner.startDialogue('start');

    // CameraComponent cam = CameraComponent.withFixedResolution(
    //   world: world,
    //   width: 1387,
    //   height: 640,
    // );

    // cam.viewfinder.anchor = Anchor.topLeft;

    addAll([
      projectViewComponent,
      // BackRouteButton(position: Vector2(20, 10)),
      PauseButton(position: Vector2(20, 10)),
    ]);
  }
}
