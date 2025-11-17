/* 

import 'package:equatable/equatable.dart';
import 'package:wankar/features/video/domain/video_entity.dart';

abstract class TimelineState extends Equatable {
  const TimelineState();

  @override
  List<Object?> get props => [];
}

class TimelineLoading extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final List<VideoEntity> videos;

  const TimelineLoaded(this.videos);

  @override
  List<Object?> get props => [videos];
}

class TimelineError extends TimelineState {
  final String message;

  const TimelineError(this.message);

  @override
  List<Object?> get props => [message];
}
 */