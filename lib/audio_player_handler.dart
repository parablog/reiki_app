import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class DualAudioHandler extends BaseAudioHandler {
  final MyAudioHandler innerHandler;
  final AudioPlayer _player = AudioPlayer();

  DualAudioHandler(this.innerHandler);

  Future<void> setAudioSource(String assetPath) async {
    await _player.setAudioSource(AudioSource.asset(assetPath));
  }

  @override
  Future<void> play() async {
    await _player.play();
    await innerHandler.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    await innerHandler.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await innerHandler.stop();
  }

  Future<void> setInnerAudioSource(String assetPath) async {
    await innerHandler.setAudioSource(assetPath);
  }
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    _player.playerStateStream.listen((state) {
      playbackState.add(
        playbackState.value.copyWith(
          playing: state.playing,
          processingState: {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[state.processingState]!,
        ),
      );
    });
  }

  @override
  Future<void> play() {
    print("playing");
    return _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  Future<void> setAudioSource(String assetPath) async {
    await _player.setAudioSource(AudioSource.asset(assetPath));
  }
}

class DualPlayerAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player1 = AudioPlayer();
  final AudioPlayer _player2 = AudioPlayer();

  DualPlayerAudioHandler() {
    // we'll listen only to the first player for playback state changes
    _player1.playerStateStream.listen((state) {
      print("player1::state: $state");

      playbackState.add(
        playbackState.value.copyWith(
          playing: state.playing,
          processingState: {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[state.processingState]!,
        ),
      );
    });

    _player1.setLoopMode(LoopMode.one);
    _player2.setLoopMode(LoopMode.all);

    _player1.setAudioSource(AudioSource.asset('assets/audio/CJ_Sterner_PerpetualMeditations.mp3'));
    _player2.setAudioSource(AudioSource.asset('assets/audio/60-seconds-with-bell.mp3'));

    _player1.positionStream.listen((position) {
      print(
        "player1::position: $position of ${_player1.duration} - ${_player2.position}",
      );
    });
  }

  Future<void> setAudioSource1(String assetPath) async {
    await _player1.setAudioSource(AudioSource.asset(assetPath));
  }

  Future<void> setAudioSource2(String assetPath) async {
    await _player2.setAudioSource(AudioSource.asset(assetPath));
  }

  @override
  Future<void> play() async {
    // Align positions before starting playback
    final position = _player1.position;
    await _player2.seek(position);

    // Start both players
    await Future.wait([_player1.play(), _player2.play()]);
  }

  @override
  Future<void> pause() async {
    await Future.wait([_player1.pause(), _player2.pause()]);
  }

  @override
  Future<void> stop() async {
    await Future.wait([_player1.pause(), _player2.pause()]);
  }

  Future<void> play1() => _player1.play();
  Future<void> play2() => _player2.play();
  Future<void> pause1() => _player1.pause();
  Future<void> pause2() => _player2.pause();
  Future<void> stop1() => _player1.stop();
  Future<void> stop2() => _player2.stop();
}
