import 'package:flutter/material.dart';

import 'web_player_controller_state.dart';

class WebPlayerController extends ValueNotifier<WebPlayerControllerState> {
  Function()? pause;
  Function()? play;
  Function(Duration duration)? seekTo;
  Function(double speed)? setPlaybackSpeed;
  late String videoId;

  bool isDisposed = false;

  WebPlayerController(super.value);

  static WebPlayerController getController(String videoId) {
    final controller = WebPlayerController(
        WebPlayerControllerState(Duration.zero, Duration.zero, false));
    controller.videoId = videoId;
    return controller;
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}
