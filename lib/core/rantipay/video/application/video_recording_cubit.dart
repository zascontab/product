// ignore_for_file: use_build_context_synchronously

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:rantipay_app/core/rantipay/video/application/video_recording_state.dart';
import 'package:rantipay_app/core/rantipay/video/presentation/video_preview_screen.dart';



class VideoRecordingCubit extends Cubit<VideoRecordingState> {
  late CameraController _cameraController;
  bool _hasPermission = false;
  List<String> _deniedPermissions = [];
  bool _isSelfieMode = false;
  double _maximumZoomLevel = 0.0;
  double _minimumZoomLevel = 0.0;
  double _currentZoomLevel = 0.0;
  final double _zoomLevelStep = 0.05;
  final bool noCamera = kDebugMode && Platform.isIOS;

  VideoRecordingCubit() : super(VideoRecordingInitial());

  CameraController get cameraController => _cameraController;

  Future<void> initPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final micPermission = await Permission.microphone.request();

    final cameraDenied =
        cameraPermission.isDenied || cameraPermission.isPermanentlyDenied;

    final micDenied =
        micPermission.isDenied || micPermission.isPermanentlyDenied;

    if (!cameraDenied && !micDenied) {
      _hasPermission = true;
      emit(VideoRecordingPermissionGranted());
      await initCamera();
    } else {
      _deniedPermissions = [
        if (cameraDenied) "Camera",
        if (micDenied) "Microphone",
      ];
      emit(VideoRecordingPermissionDenied(_deniedPermissions));
    }
  }

  Future<void> initCamera() async {
    if (noCamera) {
      return;
    }

    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      return;
    }

    _cameraController = CameraController(
      cameras[_isSelfieMode ? 1 : 0],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    await _cameraController.initialize();

    await _cameraController.prepareForVideoRecording(); // for IOS

    _maximumZoomLevel = await _cameraController.getMaxZoomLevel();
    _minimumZoomLevel = await _cameraController.getMinZoomLevel();
  }

  Future<void> toggleSelfieMode() async {
    _isSelfieMode = !_isSelfieMode;
    await initCamera();
    emit(VideoRecordingInitial()); // Refresh the UI
  }

  Future<void> setFlashMode(FlashMode newFlashMode) async {
    await _cameraController.setFlashMode(newFlashMode);
    emit(VideoRecordingInitial()); // Refresh the UI
  }

  Future<void> startVideoRecording() async {
    if (_cameraController.value.isRecordingVideo) return;

    await _cameraController.startVideoRecording();
    emit(VideoRecordingInProgress());
  }

  Future<void> stopVideoRecording(BuildContext context) async {
    if (!_cameraController.value.isRecordingVideo) return;

    final video = await _cameraController.stopVideoRecording();
    emit(VideoRecordingSuccess(video.path));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(
          video: XFile(video.path),
          isPicked: false,
        ),
      ),
    );
  }

  Future<void> pickVideo(BuildContext context) async {
    final video = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (video == null) return;

    emit(VideoRecordingSuccess(video.path));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(
          video: XFile(video.path),
          isPicked: true,
        ),
      ),
    );
  }

  void onVerticalDragUpdate(DragUpdateDetails details) async {
    if (details.delta.dy < 0 && _currentZoomLevel < _maximumZoomLevel) {
      _currentZoomLevel += _zoomLevelStep;
    } else if (details.delta.dy > 0 && _currentZoomLevel > _minimumZoomLevel) {
      _currentZoomLevel -= _zoomLevelStep;
    }
    _currentZoomLevel =
        _currentZoomLevel.clamp(_minimumZoomLevel, _maximumZoomLevel);
    await _cameraController.setZoomLevel(_currentZoomLevel);
    emit(VideoRecordingInitial()); // Refresh the UI
  }
}
