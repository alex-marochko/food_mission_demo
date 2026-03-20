import 'package:flame_audio/flame_audio.dart';

class GameSfxPlayer {
  static const _successAsset = 'catch_good.wav';
  static const _errorAsset = 'catch_bad.wav';

  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll([_successAsset, _errorAsset]);
    } catch (_) {
      // Audio is optional in tests and unsupported environments.
    }
  }

  Future<void> playCatch({required bool isTarget}) async {
    try {
      await FlameAudio.play(
        isTarget ? _successAsset : _errorAsset,
        volume: isTarget ? 0.58 : 0.48,
      );
    } catch (_) {
      // Ignore audio failures so gameplay logic stays deterministic.
    }
  }
}
