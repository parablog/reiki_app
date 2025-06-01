import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'audio_player_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await AudioService.init(
    // builder: () => MyAudioHandler(),
    // builder: () => DualAudioHandler(MyAudioHandler()),
    builder: () => DualPlayerAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.reiki_app.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(audioHandler: audioHandler));
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
    // widget.audioHandler.playFromUri(
    //   Uri.parse("assets:///assets/audio/nature.mp3"),
    // );
    /*var handler = widget.audioHandler as DualAudioHandler;
    handler.setAudioSource('assets/audio/CJ_Sterner_PerpetualMeditations.mp3');
    handler.setInnerAudioSource('assets/audio/60-seconds-with-bell.mp3');*/

    var handler = widget.audioHandler as DualPlayerAudioHandler;

    // handler.setAudioSource1('assets/audio/CJ_Sterner_PerpetualMeditations.mp3');
    // handler.setAudioSource2('assets/audio/60-seconds-with-bell.mp3');
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
