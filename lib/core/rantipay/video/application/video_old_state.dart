part of 'video_old_cubit.dart';

abstract class VideoOldState {}

class VideoInitial extends VideoOldState {}

class VideoLoading extends VideoOldState {}

class VideoLoaded extends VideoOldState {
  final List<VideoEntity> videos;

  VideoLoaded(this.videos);
}

class VideoError extends VideoOldState {
  final String message;

  VideoError(this.message);
}
