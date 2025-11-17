import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class PlaybackConfigRepositoryImpl {
  final SharedPreferences _preferences;

  PlaybackConfigRepositoryImpl(this._preferences);

  bool isMuted() {
    return _preferences.getBool('muted') ?? false;
  }

  bool isAutoplay() {
    return _preferences.getBool('autoplay') ?? false;
  }

  Future<void> setMuted(bool value) async {
    await _preferences.setBool('muted', value);
  }

  Future<void> setAutoplay(bool value) async {
    await _preferences.setBool('autoplay', value);
  }
}
