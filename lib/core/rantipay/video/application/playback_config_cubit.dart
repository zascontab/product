import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'playback_config_state.dart';

@injectable
class PlaybackConfigCubit extends Cubit<PlaybackConfigState> {
  PlaybackConfigCubit() : super(const PlaybackConfigState());

  void toggleMute() {
    emit(state.copyWith(muted: !state.muted));
  }

  void toggleAutoplay() {
    emit(state.copyWith(autoplay: !state.autoplay));
  }
}
