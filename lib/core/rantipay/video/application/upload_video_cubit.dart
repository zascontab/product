import 'dart:io';

import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/rantipay/video/application/upload_video_state.dart';
import 'package:rantipay_app/core/rantipay/video/domain/video_entity.dart';
import 'package:rantipay_app/core/rantipay/video/infrastructure/video_repository_impl.dart';



@injectable
class UploadVideoCubit extends Cubit<UploadVideoState> {
  final VideoRepositoryImpl _videoRepository;

  UploadVideoCubit(this._videoRepository) : super(UploadVideoInitial());

  Future<void> uploadVideo(File video, String title, String description,
      BuildContext context) async {
    emit(UploadVideoLoading());
    try {
      await _videoRepository.uploadVideo(VideoEntity(
          id: '', // Asignar un ID adecuado aquí
          fileUrl: '', // La URL se obtendrá después de subir el video
          title: title,
          description: description,
          creator: '', // Asignar el creador adecuado
          likes: 0,
          comments: 0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          thumbnailUrl: '',
          creatorUid: DateTime.now().toIso8601String(),
          videoFiles: []));
      emit(UploadVideoSuccess());
      Navigator.of(context)
          .pop(); // Volver a la pantalla anterior después de la subida
    } catch (e) {
      emit(UploadVideoError(e.toString()));
    }
  }
}
