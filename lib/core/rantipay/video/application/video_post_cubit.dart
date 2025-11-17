import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/rantipay/video/application/video_post_state.dart';



@injectable
class VideoPostCubit extends Cubit<VideoPostState> {
  VideoPostCubit(int initialLikes) : super(VideoPostState(likes: initialLikes));

  void toggleLike() {
    emit(state.copyWith(
      isLiked: !state.isLiked,
      likes: state.isLiked ? state.likes - 1 : state.likes + 1,
    ));
  }

  void togglePause() {
    emit(state.copyWith(isPaused: !state.isPaused));
  }
}
