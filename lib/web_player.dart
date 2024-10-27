import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // String? htmlText;

  @override
  void initState() {
    super.initState();
    // htmlText = await DefaultAssetBundle.of(context)
    //     .loadString("assets/web_player.html")
    //     .toString();
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

  Future<Widget> _player() async {
    final html = await rootBundle.loadString('assets/web_player.html');
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: html
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

  @override
  Widget build(BuildContext context) {
    if (widget.videoPlayerController == null) {
      return const SizedBox();
    }
    widget.videoPlayerController!.play = play;
    widget.videoPlayerController!.pause = pause;
    widget.videoPlayerController!.seekTo = seekTo;
    widget.videoPlayerController!.setPlaybackSpeed = setPlaybackSpeed;

    return FutureBuilder<Widget>(
      future: _player(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return snapshot.data!;
      },
    );
  }
}
String _YOUTUBE_HTML = """
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">


    <style>
        * {
            margin: 0px
        }

        body {
            height: 100vh;
            width: 100vw;
        }
    </style>

    <script>
        var youtubeController = null;

        // HTML TO FLUTTER ADAPTER

        function getState() {
            if (!youtubeController) {
                console.error("youtubeController NOT READY")
                return null;
            }

            return {
                duration: youtubeController.playerInfo.progressState.duration,
                position: youtubeController.playerInfo.progressState.current,
                isPlaying: youtubeController.playerInfo.playerState == YT.PlayerState.PLAYING,
            }
        }

        function pony_pause() {
            youtubeController.pauseVideo();
        }
        function pony_play() {
            youtubeController.playVideo()
        }
        function pony_seekTo(second) {
            youtubeController.seekTo(second);
        }
        function pony_setPlaybackSpeed(speed) {
            youtubeController.setPlaybackRate(speed);
        }

        function onPlayerReady(e) {
            console.log("onPlayerReady", e);
            youtubeController = e.target;
            youtubeController.hideVideoInfo();
        }

        function onPlayerPlaybackQualityChange(e) {
            // NOTHING TO DO
            // console.log("onPlayerPlaybackQualityChange", e)
        }

        function onPlayerStateChange(e) {

            switch (e.data) {
                case YT.PlayerState.ENDED: {
                    // 
                    break;
                }
                case YT.PlayerState.PLAYING: {
                    //
                    break;
                }
                case YT.PlayerState.PAUSED: {

                    break;
                }
                case YT.PlayerState.BUFFERING: {

                    break;
                }
                case YT.PlayerState.CUED: {

                    break;
                }
                default:
                    break;
            }

            console.log("onPlayerStateChange", e)
        }


        function onPlayerError(e) {
            console.log("onPlayerError", e)
        }


    </script>


</head>

<body>

    <iframe id="v" width="100%" height="100%"
        src="https://www.youtube.com/embed/%VIDEO_ID%?disablekb=1&enablejsapi=1&controls=0&fs=0&playsinline=1"
        title="YouTube video player" frameborder="0"
        allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
        referrerpolicy="strict-origin-when-cross-origin" donotallowfullscreen="1" allowfullscreen="0"></iframe>


    <script>
        var tag = document.createElement('script');
        tag.src = "https://www.youtube.com/player_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        var player;
        function onYouTubePlayerAPIReady() {
            player = new YT.Player(document.getElementById("v"), {
                height: window.screen.height.toString(),
                width: window.screen.width.toString(),
                videoId: "%VIDEO_ID%",
                playerVars: { 'autoplay': 1, 'controls': 0, 'showinfo': 0, 'fs': 0, 'playsinline': 1 },
                events: {
                    'onReady': onPlayerReady,
                    'onPlaybackQualityChange': onPlayerPlaybackQualityChange,
                    'onStateChange': onPlayerStateChange,
                    'onError': onPlayerError
                }
            });
        }
    </script>


</body>

</html>
""";
