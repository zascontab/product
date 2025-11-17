import 'package:equatable/equatable.dart';

class VideoState extends Equatable {
  final bool isPlaying;
  final bool isInitialized;

  const VideoState({
    required this.isPlaying,
    required this.isInitialized,
  });

  factory VideoState.initial() {
    return const VideoState(isPlaying: false, isInitialized: false);
  }

  VideoState copyWith({
    bool? isPlaying,
    bool? isInitialized,
  }) {
    return VideoState(
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [isPlaying, isInitialized];
}
