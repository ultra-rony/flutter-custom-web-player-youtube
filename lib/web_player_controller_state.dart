class WebPlayerControllerState {
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;
  bool isReady = false;

  WebPlayerControllerState(this.duration, this.position, this.isPlaying);

  WebPlayerControllerState.fromJson(Map<String, dynamic> json) {
    position = Duration(
        milliseconds:
        (double.parse(json['position'].toString()) * 1000).floor());
    duration = Duration(
        milliseconds:
        (double.parse(json['duration'].toString()) * 1000).floor());
    isPlaying = bool.parse(json['isPlaying']);
  }
}