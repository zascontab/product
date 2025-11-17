import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/rantipay/video/application/bloc/timeline_event.dart';
import 'package:rantipay_app/core/rantipay/video/infrastructure/video_repository_impl.dart';


import 'timeline_state.dart';

@injectable
class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final VideoRepositoryImpl _videoRepository;

  TimelineBloc(this._videoRepository) : super(TimelineLoading()) {
    on<FetchVideos>(_onFetchVideos);
    on<FetchNextPage>(_onFetchNextPage);
    on<RefreshTimeline>(_onRefreshTimeline);
  }

  Future<void> _onFetchVideos(
      FetchVideos event, Emitter<TimelineState> emit) async {
    try {
      final videos = await _videoRepository.fetchVideos();
      emit(TimelineLoaded(videos));
    } catch (e) {
      emit(TimelineError(e.toString()));
    }
  }

  Future<void> _onFetchNextPage(
      FetchNextPage event, Emitter<TimelineState> emit) async {
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

  Future<void> _onRefreshTimeline(
      RefreshTimeline event, Emitter<TimelineState> emit) async {
    try {
      final videos = await _videoRepository.fetchVideos();
      emit(TimelineLoaded(videos));
    } catch (e) {
      emit(TimelineError(e.toString()));
    }
  }
}
