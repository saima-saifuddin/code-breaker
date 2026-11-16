
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class SoundService with WidgetsBindingObserver {
  static final SoundService instance = SoundService();

  // Separate players for separate jobs
  final AudioPlayer backgroundPlayer = AudioPlayer();
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer wrongAudioPlayer = AudioPlayer();
  final AudioPlayer gameOverPlayer = AudioPlayer();
  final AudioPlayer challengeCompletePlayer = AudioPlayer();


  bool soundEnabled = true;
  bool vibrationEnabled = true;

  // ---- Main game sound (looping background player) ----
  bool _bgInitialized = false;
  bool _bgRunning = false; // true only while the loop is meant to be playing
  int _bgToken = 0; // invalidates an in-flight start if stop is called

  // True while the Challenge Complete / Game Over sound owns the audio.
  // While true, the main game sound must not start (not even from a
  // lifecycle resume or the Sound switch). Cleared by resumeGameplaySound().
  bool _resultAudioActive = false;

  // Wrong Answer / click / main sound must not take Android audio focus.
  // Every AudioPlayer requests AUDIOFOCUS_GAIN by default, so playing the
  // Wrong Answer sound made Android send a permanent focus-loss to the main
  // sound player, which then paused itself and never recovered.
  // "Mix with others" = no focus request, so these players never pause each other.
  Future<void>? _mixingReady;
  Future<void> _ensureMixing() => _mixingReady ??= _applyMixing();

  Future<void> _applyMixing() async {
    try {
      final ctx = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();
      await backgroundPlayer.setAudioContext(ctx);
      await audioPlayer.setAudioContext(ctx);
      await wrongAudioPlayer.setAudioContext(ctx);
    } catch (_) {}
  }

  /// Call once at app start. Registers the lifecycle observer and starts the
  /// main game sound if Sound is ON.
  void init() {
    if (_bgInitialized) return;
    _bgInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    startBackgroundSound();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check the Sound setting when the game comes back to the foreground.
      startBackgroundSound();
    } else if (state == AppLifecycleState.inactive) {
      // Notification panel / system overlay: the game is still visible, so
      // the main game sound keeps playing. (A real background move always
      // continues to paused/hidden below, which still stops it.)
    } else {
      // paused / hidden / detached: never play outside the game.
      stopBackgroundSound();
    }
  }

  Future<void> startBackgroundSound() async {
    if (!soundEnabled) return;
    if (_resultAudioActive) return; // result screen sound has priority
    if (_bgRunning) {
      // Already running: no duplicate instance. If the system paused it
      // (e.g. temporary audio focus loss), continue it.
      try {
        if (backgroundPlayer.state == PlayerState.paused) {
          await backgroundPlayer.resume();
        }
      } catch (_) {}
      return;
    }
    _bgRunning = true;
    final token = ++_bgToken;
    try {
      await _ensureMixing();
      await backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      // Stop/start or lifecycle change happened while we were awaiting.
      if (token != _bgToken || !soundEnabled) return;
      await backgroundPlayer.play(AssetSource('sounds/click.mp3'));
      if (token != _bgToken || !soundEnabled) {
        await backgroundPlayer.stop();
      }
    } catch (_) {
      if (token == _bgToken) _bgRunning = false;
    }
  }

  Future<void> stopBackgroundSound() async {
    _bgRunning = false;
    _bgToken++;
    await backgroundPlayer.stop();
  }

  // Sound switch: ON = loop music, OFF = stop all sounds
  Future<void> toggleSound(bool enabled) async {
    soundEnabled = enabled;

    if (enabled) {
      await startBackgroundSound();
    } else {
      await stopBackgroundSound();
      await audioPlayer.stop();
    }
  }

  /// Call when an active gameplay screen is shown. Gives the audio back to
  /// the main game sound (only if the saved Sound setting is ON).
  Future<void> resumeGameplaySound() async {
    _resultAudioActive = false;
    await startBackgroundSound();
  }

  // Stop the Game Over sound (called when leaving the Game Over screen).
  Future<void> stopGameOverSound() async {
    await gameOverPlayer.stop();
  }

  // Stop the Challenge Complete sound (called when leaving that screen).
  Future<void> stopChallengeCompleteSound() async {
    await challengeCompletePlayer.stop();
  }

  // Button click sound
  Future<void> playClickSound() async {
    if (!soundEnabled) return;

    await _ensureMixing();
    await audioPlayer.setReleaseMode(ReleaseMode.release);
    await audioPlayer.play(
      AssetSource('sounds/click.mp3'),
    );
  }
  // game over sound
  Future<void> playGameOverSound() async {
    // Game Over has priority: stop the main game sound first.
    _resultAudioActive = true;
    await stopBackgroundSound();
    await challengeCompletePlayer.stop();
    if (!soundEnabled) return;

    await gameOverPlayer.setReleaseMode(ReleaseMode.release);
    await gameOverPlayer.play(
      AssetSource('sounds/game_over.mp3'),
    );
  }
  // challenge complete sound
  Future<void> playChallengeCompleteSound() async {
    // Challenge Complete has priority: stop the main game sound first.
    _resultAudioActive = true;
    await stopBackgroundSound();
    await gameOverPlayer.stop();
    if (!soundEnabled) return;

    await challengeCompletePlayer.setReleaseMode(
      ReleaseMode.release,
    );

    await challengeCompletePlayer.play(
      AssetSource('sounds/challenge_complete.mp3'),
    );
  }

  // Wrong-answer sound
  Future<void> playWrongSound() async {
    if (!soundEnabled) return;

    await _ensureMixing();
    await wrongAudioPlayer.setReleaseMode(ReleaseMode.release);
    await wrongAudioPlayer.play(
      AssetSource('sounds/wrong.mp3'),
    );
  }

  // Vibration switch: independent from sound
  Future<void> toggleVibration(bool enabled) async {
    vibrationEnabled = enabled;

    if (!enabled && !kIsWeb) {
      await Vibration.cancel();
    }
  }

  // Call this wherever vibration is needed
  Future<void> playVibration() async {
    if (!vibrationEnabled || kIsWeb) return;

    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator == true) {
      await Vibration.vibrate(duration: 1000);
    }
  }
}
