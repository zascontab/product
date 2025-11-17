import 'package:equatable/equatable.dart';

abstract class UploadVideoState extends Equatable {
  const UploadVideoState();

  @override
  List<Object?> get props => [];
}

class UploadVideoInitial extends UploadVideoState {}

class UploadVideoLoading extends UploadVideoState {}

class UploadVideoSuccess extends UploadVideoState {}

class UploadVideoError extends UploadVideoState {
  final String message;

  const UploadVideoError(this.message);

  @override
  List<Object?> get props => [message];
}
