import 'dart:async';

import 'package:flutter/material.dart';

import 'web_player.dart';
import 'web_player_controller.dart';
import 'web_player_controller_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  WebPlayerController? ytController;
  WebPlayerControllerState? ytState;

  final StreamController<int> _streamer = StreamController<int>.broadcast();

  Timer? timer;
  double slide = 0;

  @override
  void initState() {
    ytController = WebPlayerController.getController("BTBrvavD4GA");
    ytState = ytController!.value;
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _streamer.add(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height / 3,
            child: WebPlayer(
              key: const ValueKey(321231213),
              videoPlayerController: ytController,
            ),
          ),
          Expanded(
            child: StreamBuilder<int>(
                initialData: 0,
                stream: _streamer.stream,
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      ElevatedButton(
                          child: Text("${ytController!.value.duration}"),
                          onPressed: () {}),
                      ElevatedButton(
                          child: Text("${ytController!.value.position}"),
                          onPressed: () {}),
                      Expanded(
                          child: Column(
                            children: [
                              ElevatedButton(
                                  child: Icon(
                                    !ytController!.value.isPlaying
                                        ? Icons.play_circle
                                        : Icons.pause_circle,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    if (ytController!.value.isPlaying) {
                                      ytController?.pause?.call();
                                    } else {
                                      ytController?.play?.call();
                                    }
                                  }),
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: ElevatedButton(
                                            child: const Text("-10"),
                                            onPressed: () {
                                              ytController!.seekTo!(
                                                  ytController!.value.position -
                                                      const Duration(seconds: 10))?.call();
                                            })),
                                    Expanded(
                                        child: ElevatedButton(
                                            child: const Text("+10"),
                                            onPressed: () {
                                              ytController?.seekTo!(
                                                  ytController!.value.position +
                                                      const Duration(seconds: 10)).call();
                                            })),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: ElevatedButton(
                                            child: const Text("0,25"),
                                            onPressed: () {
                                              ytController?.setPlaybackSpeed!(0.25).call();
                                            })),
                                    Expanded(
                                        child: ElevatedButton(
                                            child: const Text("0,5"),
                                            onPressed: () {
                                              ytController?.setPlaybackSpeed!(0.5).call();
                                            })),
                                    Expanded(
                                        child: ElevatedButton(
                                            child: const Text("1"),
                                            onPressed: () {
                                              ytController?.setPlaybackSpeed!(1).call();
                                            })),
                                    Expanded(
                                        child: ElevatedButton(
                                            child: const Text("1.5"),
                                            onPressed: () {
                                              ytController?.setPlaybackSpeed!(1.5).call();
                                            })),
                                    Expanded(
                                        child: ElevatedButton(
                                            child: const Text("2"),
                                            onPressed: () {
                                              ytController?.setPlaybackSpeed!(2).call();
                                            })),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
