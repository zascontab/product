import 'package:equatable/equatable.dart';

abstract class TimelineEvent extends Equatable {
  const TimelineEvent();

  @override
  List<Object?> get props => [];
}

class FetchVideos extends TimelineEvent {}

class FetchNextPage extends TimelineEvent {}

class RefreshTimeline extends TimelineEvent {}
