abstract class VideoRecordingState {}

class VideoRecordingInitial extends VideoRecordingState {}

class VideoRecordingPermissionGranted extends VideoRecordingState {}

class VideoRecordingPermissionDenied extends VideoRecordingState {
  final List<String> deniedPermissions;

  VideoRecordingPermissionDenied(this.deniedPermissions);
}

class VideoRecordingInProgress extends VideoRecordingState {}

class VideoRecordingSuccess extends VideoRecordingState {
  final String videoPath;

  VideoRecordingSuccess(this.videoPath);
}

class VideoRecordingFailure extends VideoRecordingState {
  final String message;

  VideoRecordingFailure(this.message);
}
