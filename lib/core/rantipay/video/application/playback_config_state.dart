import 'package:equatable/equatable.dart';

class PlaybackConfigState extends Equatable {
  final bool muted;
  final bool autoplay;

  const PlaybackConfigState({
    this.muted = false,
    this.autoplay = false,
  });

  PlaybackConfigState copyWith({
    bool? muted,
    bool? autoplay,
  }) {
    return PlaybackConfigState(
      muted: muted ?? this.muted,
      autoplay: autoplay ?? this.autoplay,
    );
  }

  @override
  List<Object?> get props => [muted, autoplay];
}
