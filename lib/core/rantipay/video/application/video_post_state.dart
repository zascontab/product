import 'package:equatable/equatable.dart';

class VideoPostState extends Equatable {
  final bool isLiked;
  final bool isPaused;
  final int likes;

  const VideoPostState({
    this.isLiked = false,
    this.isPaused = false,
    this.likes = 0,
  });

  VideoPostState copyWith({
    bool? isLiked,
    bool? isPaused,
    int? likes,
  }) {
    return VideoPostState(
      isLiked: isLiked ?? this.isLiked,
      isPaused: isPaused ?? this.isPaused,
      likes: likes ?? this.likes,
    );
  }

  @override
  List<Object?> get props => [isLiked, isPaused, likes];
}
