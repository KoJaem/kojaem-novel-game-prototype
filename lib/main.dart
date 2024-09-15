import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:kojaem_novel_game_prototype/route.dart';
// import 'package:kojaem_novel_game_prototype/project_view_component.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // // * 모바일 배포 시
  // runApp(GameWidget(
  //   game: JennyGame(),
  // ));

  runApp(GameWidget(game: RouterGame()));

  // * 웹 배포 시 (비율고정)
  // runApp(GameWidget(
  //     game: JennyGame(
  //   camera: CameraComponent.withFixedResolution(
  //     width: 932,
  //     height: 430,
  //   ),
  // )));
}
