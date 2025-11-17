import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object> get props => [];
}

class VideoPlayPauseToggled extends VideoEvent {
  final int index;

  const VideoPlayPauseToggled(this.index);

  @override
  List<Object> get props => [index];
}

class VideoInitialized extends VideoEvent {
  final int index;

  const VideoInitialized(this.index);

  @override
  List<Object> get props => [index];
}
