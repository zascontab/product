import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rantipay_app/core/rantipay/gaps.dart';
import 'package:rantipay_app/core/rantipay/sizes.dart';
import 'package:rantipay_app/core/rantipay/video/application/playback_config_cubit.dart' show PlaybackConfigCubit;
import 'package:rantipay_app/core/rantipay/video/application/video_bloc.dart';
import 'package:rantipay_app/core/rantipay/video/application/video_event.dart';
import 'package:rantipay_app/core/rantipay/video/application/video_post_cubit.dart';
import 'package:rantipay_app/core/rantipay/video/application/video_post_state.dart';
import 'package:rantipay_app/core/rantipay/video/domain/video_entity.dart';
import 'package:rantipay_app/core/rantipay/video/presentation/widgets/video_button.dart';
import 'package:rantipay_app/core/rantipay/video/presentation/widgets/video_comments.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';



class VideoPost extends StatelessWidget {
  final Function onVideoFinished;
  final VideoEntity videoData;
  final int index;
  final bool isPlaying;

  const VideoPost({
    super.key,
    required this.videoData,
    required this.onVideoFinished,
    required this.index,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PlaybackConfigCubit(),
        ),
        BlocProvider(
          create: (_) => VideoPostCubit(videoData.likes),
        ),
        BlocProvider(
          create: (_) => VideoBloc(),
        ),
      ],
      child: VideoPostView(
        videoData: videoData,
        onVideoFinished: onVideoFinished,
        index: index,
        isPlaying: isPlaying,
      ),
    );
  }
}

class VideoPostView extends StatefulWidget {
  final Function onVideoFinished;
  final VideoEntity videoData;
  final int index;
  final bool isPlaying;

  const VideoPostView({
    super.key,
    required this.videoData,
    required this.onVideoFinished,
    required this.index,
    required this.isPlaying,
  });

  @override
  _VideoPostViewState createState() => _VideoPostViewState();
}

class _VideoPostViewState extends State<VideoPostView>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  late AnimationController _animationController;
  final Duration _animationDuration = const Duration(milliseconds: 200);
  bool _showDetail = false;
  bool _isPaused = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.5,
      value: 1.5,
      duration: _animationDuration,
    );
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoData.fileUrl))
          ..addListener(_onVideoChange)
          ..setLooping(true);

    try {
      await _videoPlayerController.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          if (widget.isPlaying) {
            _videoPlayerController.play();
          }
        });
        context.read<VideoBloc>().add(VideoInitialized(widget.index));
      }
    } catch (e) {
      print("Error initializing video player: $e");
    }
  }

  void _onVideoChange() {
    if (_isInitialized &&
        _videoPlayerController.value.position ==
            _videoPlayerController.value.duration) {
      if (mounted) {
        widget.onVideoFinished();
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPlaybackConfigChanged() {
    if (mounted) {
      final playbackCubit = context.read<PlaybackConfigCubit>();
      playbackCubit.toggleMute();
      if (playbackCubit.state.muted) {
        _videoPlayerController.setVolume(0);
      } else {
        _videoPlayerController.setVolume(1);
      }
    }
  }

  void _onTogglePause() {
    if (_isInitialized) {
      final videoBloc = context.read<VideoBloc>();
      videoBloc.add(VideoPlayPauseToggled(widget.index));

      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }

      setState(() {
        _isPaused = !_isPaused;
      });
    }
  }

  Future<void> _onCommentsTap(BuildContext context) async {
    if (_videoPlayerController.value.isPlaying) {
      _onTogglePause();
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VideoComments(),
    );
    if (mounted) {
      _onTogglePause();
    }
  }

  void toggleDetail() {
    setState(() {
      _showDetail = !_showDetail;
    });
  }

  String handleDetail(String payload) {
    if (payload.length <= 20) {
      return payload;
    }
    return _showDetail ? payload : "${payload.substring(0, 20)}...";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPlaying &&
        _isInitialized &&
        !_videoPlayerController.value.isPlaying &&
        !_isPaused) {
      _videoPlayerController.play();
    }

    return VisibilityDetector(
      key: Key("${widget.index}"),
      onVisibilityChanged: (info) {
        if (mounted && _isInitialized) {
          if (info.visibleFraction == 1 &&
              !_isPaused &&
              !_videoPlayerController.value.isPlaying) {
            _videoPlayerController.play();
          }
          if (_videoPlayerController.value.isPlaying &&
              info.visibleFraction == 0) {
            _videoPlayerController.pause();
          }
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: _isInitialized
                ? VideoPlayer(_videoPlayerController)
                : Image.network(
                    widget.videoData.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: _onTogglePause,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animationController.value,
                      child: child,
                    );
                  },
                  child: AnimatedOpacity(
                    opacity: _isPaused ? 1 : 0,
                    duration: _animationDuration,
                    child: const FaIcon(
                      FontAwesomeIcons.play,
                      color: Colors.white,
                      size: Sizes.size52,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 40,
            child: IconButton(
              icon: FaIcon(
                context.read<PlaybackConfigCubit>().state.muted
                    ? FontAwesomeIcons.volumeXmark
                    : FontAwesomeIcons.volumeHigh,
                color: Colors.white,
              ),
              onPressed: _onPlaybackConfigChanged,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${widget.videoData.creator}",
                  style: const TextStyle(
                    fontSize: Sizes.size20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                Gaps.v10,
                AnimatedCrossFade(
                  duration: const Duration(microseconds: 2000),
                  firstChild: Container(),
                  secondChild: Text(
                    handleDetail(widget.videoData.description),
                    style: const TextStyle(
                      fontSize: Sizes.size16,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  crossFadeState: _showDetail
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: Sizes.size200,
                      child: _showDetail
                          ? Container()
                          : Text(
                              handleDetail(widget.videoData.description),
                              style: const TextStyle(
                                fontSize: Sizes.size16,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                    ),
                    GestureDetector(
                      onTap: toggleDetail,
                      child: Text(
                        _showDetail ? "less" : "more",
                        style: const TextStyle(
                          fontSize: Sizes.size16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _onPlaybackConfigChanged,
                  child: VideoButton(
                    icon: context.read<PlaybackConfigCubit>().state.muted
                        ? FontAwesomeIcons.volumeXmark
                        : FontAwesomeIcons.volumeHigh,
                  ),
                ),
                Gaps.v24,
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  foregroundImage: const AssetImage('assets/avatar_2.png'),
                  child: Text(
                    widget.videoData.creator,
                    style: const TextStyle(
                      fontSize: 10,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Gaps.v24,
                GestureDetector(
                  onTap: () {
                    context.read<VideoPostCubit>().toggleLike();
                  },
                  child: BlocBuilder<VideoPostCubit, VideoPostState>(
                    builder: (context, state) {
                      return VideoButton(
                        icon: FontAwesomeIcons.solidHeart,
                        color: state.isLiked ? Colors.red : Colors.white,
                        text: '${state.likes}',
                      );
                    },
                  ),
                ),
                Gaps.v24,
                GestureDetector(
                  onTap: () => _onCommentsTap(context),
                  child: const VideoButton(
                    icon: FontAwesomeIcons.solidComment,
                    text: 'Comentarios',
                  ),
                ),
                Gaps.v24,
                const VideoButton(
                  icon: FontAwesomeIcons.share,
                  text: "Share",
                ),
              ],
            ),
          ),
          Positioned(
            top: 100,
            left: 10,
            right: 10,
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'Ricos en Nutrientes: Llenos de proteínas, vitaminas y minerales para apoyar un estilo de vida saludable.....',
                  textStyle: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  speed: Duration(milliseconds: _calculateTypingSpeed()),
                ),
              ],
              isRepeatingAnimation: false,
              onFinished: () {
                // Optional: Handle the event when animation is finished
              },
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTypingSpeed() {
    final videoDuration = _videoPlayerController.value.duration.inSeconds;
    if (videoDuration == 0) {
      return 100; // Valor por defecto si la duración del video no es válida
    }
    final textLength = 123; // Longitud del texto del TyperAnimatedText
    final baseSpeed = 100; // Velocidad base para el TyperAnimatedText
    return (videoDuration * 1000) ~/ textLength;
  }
}
