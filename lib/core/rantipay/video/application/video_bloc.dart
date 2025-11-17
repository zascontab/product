import 'package:bloc/bloc.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(VideoState.initial()) {
    on<VideoPlayPauseToggled>((event, emit) {
      emit(state.copyWith(isPlaying: !state.isPlaying));
    });

    on<VideoInitialized>((event, emit) {
      emit(state.copyWith(isInitialized: true));
    });
  }
}
