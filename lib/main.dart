import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_player_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await AudioService.init(
    builder: () => AnalyticsAudioHandler(MyAudioHandler()),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.reiki_app.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(audioHandler: audioHandler));
}

class AnalyticsAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  late AudioHandler _handler;

  AnalyticsAudioHandler(AudioHandler handler) {
    _handler = handler;

    _player.playerStateStream.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        playing: state.playing,
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[state.processingState]!,
      ));
    });
  }

  @override
  Future<void> play() async {
    print("playing");
    playFromUri(Uri.parse("assets:///assets/audio/CJ_Sterner_PerpetualMeditations.mp3"));
    _handler.playFromUri(Uri.parse("assets:///assets/audio/60-seconds-with-bell.mp3"));

    return _player.play();
  }

  @override
  Future<void> pause() async {
    return _player.pause();
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }
}

class MyApp extends StatelessWidget {
  final AudioHandler audioHandler;
  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Audio Demo',
      home: AudioPlayerScreen(audioHandler: audioHandler),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  final AudioHandler audioHandler;
  const AudioPlayerScreen({super.key, required this.audioHandler});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    widget.audioHandler.playFromUri(Uri.parse("assets:///assets/audio/bell_xs.mp3"));
        //.setAudioSource('assets/audio/CJ_Sterner_PerpetualMeditations.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Background Audio')),
      body: Center(
        child: StreamBuilder<PlaybackState>(
          stream: widget.audioHandler.playbackState,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (playing) {
                      widget.audioHandler.pause();
                    } else {
                      widget.audioHandler.play();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => widget.audioHandler.stop(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}