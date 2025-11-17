import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rantipay_app/core/di/service_container.dart';
import 'package:rantipay_app/core/package/gallery_saver/gallery_saver.dart';
import 'package:rantipay_app/core/rantipay/video/application/upload_video_cubit.dart';
import 'package:rantipay_app/core/rantipay/video/application/upload_video_state.dart';
import 'package:rantipay_app/core/widgets/loading_spinner.dart';

import 'package:video_player/video_player.dart';


class VideoPreviewScreen extends StatelessWidget {
  final XFile video;
  final bool isPicked;

  const VideoPreviewScreen({
    super.key,
    required this.video,
    required this.isPicked,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadVideoCubit>(),
      child: VideoPreviewView(video: video, isPicked: isPicked),
    );
  }
}

class VideoPreviewView extends StatefulWidget {
  final XFile video;
  final bool isPicked;

  const VideoPreviewView({
    super.key,
    required this.video,
    required this.isPicked,
  });

  @override
  VideoPreviewViewState createState() => VideoPreviewViewState();
}

class VideoPreviewViewState extends State<VideoPreviewView> {
  late final VideoPlayerController _videoPlayerController;
  bool _savedVideo = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _initVideo() async {
    _videoPlayerController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.setVolume(0);
    // await _videoPlayerController.play();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _saveToGallery() async {
    if (_savedVideo) return;

    await GallerySaver.saveVideo(
      widget.video.path,
      albumName: "TikTok Clone!",
    );

    _savedVideo = true;

    setState(() {});
  }

  void _onUploadPressed(BuildContext context) async {
    context.read<UploadVideoCubit>().uploadVideo(
          File(widget.video.path),
          _titleController.text,
          _descriptionController.text,
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Preview video'),
        actions: [
          if (!widget.isPicked)
            IconButton(
              onPressed: _saveToGallery,
              icon: FaIcon(
                _savedVideo
                    ? FontAwesomeIcons.check
                    : FontAwesomeIcons.download,
              ),
            ),
          BlocBuilder<UploadVideoCubit, UploadVideoState>(
            builder: (context, state) {
              if (state is UploadVideoLoading) {
                return const LoadingSpinner();
              }
              return IconButton(
                onPressed: () => _onUploadPressed(context),
                icon: const FaIcon(FontAwesomeIcons.cloudArrowUp),
              );
            },
          ),
        ],
      ),
      body: _videoPlayerController.value.isInitialized
          ? Stack(
              children: [
                VideoPlayer(_videoPlayerController),
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                      controller: _titleController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                      controller: _descriptionController,
                    ),
                  ],
                ),
              ],
            )
          : null,
    );
  }
}
