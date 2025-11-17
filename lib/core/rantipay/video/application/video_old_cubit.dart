import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/rantipay/video/domain/video_entity.dart';
import 'package:rantipay_app/core/rantipay/video/infrastructure/video_repository_impl.dart';



part 'video_old_state.dart';

@injectable
class VideoCubit extends Cubit<VideoOldState> {
  final VideoRepositoryImpl _repository;

  VideoCubit(this._repository) : super(VideoInitial());

  Future<void> fetchVideos() async {
    emit(VideoLoading());
    try {
      final videos = await _repository.fetchVideos();
      emit(VideoLoaded(videos));
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }

  Future<void> likeVideo(String videoId, String userId) async {
    try {
      await _repository.likeVideo(videoId, userId);
      /*  final updatedVideos = state.videos.map((video) {
        if (video.id == videoId) {
          return video.copyWith(likes: video.likes + 1);
        }
        return video;
      }).toList();
      emit(VideoLoaded(updatedVideos)); */
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }
}
