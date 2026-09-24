library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class LogoAudioManager {
  static const String _hurtSoundAsset = 'sounds/ouch.mp3';
  static const String _sadSoundAsset = 'sounds/sigh.mp3';
  static const String _happySoundAsset = 'sounds/happy.mp3';

  late final AudioPlayer _hurtPlayer;
  late final AudioPlayer _sadPlayer;
  late final AudioPlayer _happyPlayer;

  bool _muted = false;

  LogoAudioManager() {
    _hurtPlayer = AudioPlayer();
    _sadPlayer = AudioPlayer();
    _happyPlayer = AudioPlayer();

    _hurtPlayer.setReleaseMode(ReleaseMode.stop);
    _sadPlayer.setReleaseMode(ReleaseMode.stop);
    _happyPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void setMuted(bool value) {
    if (_muted == value) return;
    _muted = value;
    if (value) {
      try {
        _hurtPlayer.stop();
      } catch (_) {}
      try {
        _sadPlayer.stop();
      } catch (_) {}
      try {
        _happyPlayer.stop();
      } catch (_) {}
    }
  }

  Future<void> playHurt() => _play(_hurtPlayer, _hurtSoundAsset, 'hurt');
  Future<void> playSad() => _play(_sadPlayer, _sadSoundAsset, 'sad');
  Future<void> playHappy() => _play(_happyPlayer, _happySoundAsset, 'happy');

  Future<void> _play(AudioPlayer player, String asset, String label) async {
    if (_muted) {
      debugPrint('LogoAudioManager: $label skipped (muted)');
      return;
    }
    try {
      await player.stop();
      await player.play(AssetSource(asset));
      debugPrint('LogoAudioManager: playing $label');
    } catch (e) {
      debugPrint('LogoAudioManager: $label sound failed → $e');
    }
  }

  void dispose() {
    _hurtPlayer.dispose();
    _sadPlayer.dispose();
    _happyPlayer.dispose();
  }
}
