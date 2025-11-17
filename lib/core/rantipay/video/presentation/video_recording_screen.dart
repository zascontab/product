import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rantipay_app/core/di/service_container.dart';
import 'package:rantipay_app/core/rantipay/gaps.dart';
import 'package:rantipay_app/core/rantipay/sizes.dart';
import 'package:rantipay_app/core/rantipay/video/application/video_recording_cubit.dart';
import 'package:rantipay_app/core/rantipay/video/application/video_recording_state.dart';


import 'video_preview_screen.dart';
import 'widgets/video_flash_button.dart';

class VideoRecordingScreen extends StatelessWidget {
  static const String routeName = "postVideo";
  static const String routeURL = "/upload";
  const VideoRecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VideoRecordingCubit>()..initPermissions(),
      child: VideoRecordingView(),
    );
  }
}

class VideoRecordingView extends StatefulWidget {
  const VideoRecordingView({super.key});

  @override
  _VideoRecordingViewState createState() => _VideoRecordingViewState();
}

class _VideoRecordingViewState extends State<VideoRecordingView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _buttonAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _buttonAnimation =
        Tween(begin: 1.0, end: 1.3).animate(_buttonAnimationController);

    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _progressAnimationController.addListener(() {
      setState(() {});
    });
    _progressAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.read<VideoRecordingCubit>().stopVideoRecording(context);
      }
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _buttonAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<VideoRecordingCubit>();
    if (state == AppLifecycleState.inactive) {
      cubit.cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      cubit.initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoRecordingCubit, VideoRecordingState>(
      builder: (context, state) {
        final cubit = context.read<VideoRecordingCubit>();
        if (state is VideoRecordingPermissionGranted) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!cubit.noCamera &&
                      cubit.cameraController.value.isInitialized)
                    CameraPreview(cubit.cameraController),
                  const Positioned(
                    top: Sizes.size40,
                    left: Sizes.size20,
                    child: CloseButton(
                      color: Colors.white,
                    ),
                  ),
                  if (!cubit.noCamera)
                    Positioned(
                      top: Sizes.size20,
                      right: Sizes.size20,
                      child: Column(
                        children: [
                          IconButton(
                            color: Colors.white,
                            onPressed: () => cubit.toggleSelfieMode(),
                            icon: const Icon(
                              Icons.cameraswitch,
                            ),
                          ),
                          Gaps.v10,
                          VideoFlashButton(
                            flashMode: cubit.cameraController.value.flashMode,
                            targetMode: FlashMode.off,
                            setFlashMode: cubit.setFlashMode,
                            icon: Icons.flash_off_rounded,
                          ),
                          Gaps.v10,
                          VideoFlashButton(
                            flashMode: cubit.cameraController.value.flashMode,
                            targetMode: FlashMode.always,
                            setFlashMode: cubit.setFlashMode,
                            icon: Icons.flash_on_rounded,
                          ),
                          Gaps.v10,
                          VideoFlashButton(
                            flashMode: cubit.cameraController.value.flashMode,
                            targetMode: FlashMode.auto,
                            setFlashMode: cubit.setFlashMode,
                            icon: Icons.flash_auto_rounded,
                          ),
                          Gaps.v10,
                          VideoFlashButton(
                            flashMode: cubit.cameraController.value.flashMode,
                            targetMode: FlashMode.torch,
                            setFlashMode: cubit.setFlashMode,
                            icon: Icons.flashlight_on_rounded,
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    bottom: Sizes.size40,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onVerticalDragUpdate: (details) =>
                              cubit.onVerticalDragUpdate(details),
                          onTapDown: (_) => cubit.startVideoRecording(),
                          onTapUp: (_) => cubit.stopVideoRecording(context),
                          child: ScaleTransition(
                            scale: _buttonAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: Sizes.size80 + Sizes.size14,
                                  height: Sizes.size80 + Sizes.size14,
                                  child: CircularProgressIndicator(
                                    color: Colors.red.shade400,
                                    strokeWidth: Sizes.size6,
                                    value: _progressAnimationController.value,
                                  ),
                                ),
                                Container(
                                  width: Sizes.size80,
                                  height: Sizes.size80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: () => cubit.pickVideo(context),
                              icon: const FaIcon(
                                FontAwesomeIcons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        } else if (state is VideoRecordingPermissionDenied) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Initializing...",
                  style: TextStyle(color: Colors.white, fontSize: Sizes.size20),
                ),
                Gaps.v20,
                const CircularProgressIndicator.adaptive(),
                Gaps.v20,
                const Text(
                  "Please grant the following permissions:",
                  style: TextStyle(color: Colors.white, fontSize: Sizes.size20),
                ),
                Gaps.v20,
                Text(
                  "• ${state.deniedPermissions.join(", ")}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: Sizes.size20),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.black,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
