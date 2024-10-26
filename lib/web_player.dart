import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'web_player_controller.dart';
import 'web_player_controller_state.dart';

class WebPlayer extends StatefulWidget {
  final WebPlayerController? videoPlayerController;

  const WebPlayer({
    super.key,
    required this.videoPlayerController,
  });

  @override
  State<WebPlayer> createState() => _WebPlayerState();
}

class _WebPlayerState extends State<WebPlayer> {
  InAppWebViewController? controller;

  Timer? getStateInterval;
  String? htmlText;

  @override
  void initState() {
    super.initState();
    htmlText = DefaultAssetBundle.of(context)
        .loadString("assets/web_player.html")
        .toString();
    getStateInterval =
        Timer.periodic(const Duration(milliseconds: 100), (res) async {
      final response =
          await controller?.evaluateJavascript(source: "getState()");
      if (response != null) {
        if (widget.videoPlayerController?.isDisposed == true) {
          return;
        }

        final newMap = <String, dynamic>{};
        for (final entry in response.entries) {
          newMap[entry.key.toString()] = entry.value.toString();
        }
        final state = WebPlayerControllerState.fromJson(newMap);
        widget.videoPlayerController?.value.isReady = true;
        widget.videoPlayerController?.value = state;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    getStateInterval?.cancel();
  }

  void play() {
    controller?.evaluateJavascript(source: "pony_play()");
  }

  void pause() {
    controller?.evaluateJavascript(source: "pony_pause()");
  }

  void seekTo(Duration duration) {
    controller?.evaluateJavascript(
        source: "pony_seekTo(${duration.inMilliseconds / 1000})");
  }

  void setPlaybackSpeed(double speed) {
    controller?.evaluateJavascript(source: "pony_setPlaybackSpeed($speed)");
  }

  void isReady(double speed) {
    controller?.evaluateJavascript(source: "pony_setPlaybackSpeed($speed)");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoPlayerController == null) {
      return const SizedBox();
    }
    widget.videoPlayerController!.play = play;
    widget.videoPlayerController!.pause = pause;
    widget.videoPlayerController!.seekTo = seekTo;
    widget.videoPlayerController!.setPlaybackSpeed = setPlaybackSpeed;

    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: htmlText!
            .replaceAll("%VIDEO_ID%", widget.videoPlayerController!.videoId),
      ),
      initialSettings: InAppWebViewSettings(
        iframeAllowFullscreen: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        this.controller = controller;
      },
      onConsoleMessage: (controller, consoleMessage) {},
    );
  }
}
