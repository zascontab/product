/* import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wankar/features/video/application/timeline_state.dart';

import '../infrastructure/video_repository_impl.dart';


@injectable
class TimelineCubit extends Cubit<TimelineState> {
  final VideoRepositoryImpl _videoRepository;

  TimelineCubit(this._videoRepository) : super(TimelineLoading());

  Future<void> fetchVideos() async {
    try {
      final videos = await _videoRepository.fetchVideos();
      emit(TimelineLoaded(videos));
    } catch (e) {
      emit(TimelineError(e.toString()));
    }
  }

  Future<void> fetchNextPage() async {
    if (state is TimelineLoaded) {
      final currentState = state as TimelineLoaded;
      try {
        final videos = await _videoRepository.fetchVideos(
            lastItemCreatedAt: currentState.videos.last.createdAt);
        emit(TimelineLoaded(currentState.videos + videos));
      } catch (e) {
        emit(TimelineError(e.toString()));
      }
    }
  }

  Future<void> refresh() async {
    try {
      final videos = await _videoRepository.fetchVideos();
      emit(TimelineLoaded(videos));
    } catch (e) {
      emit(TimelineError(e.toString()));
    }
  }
}
 */