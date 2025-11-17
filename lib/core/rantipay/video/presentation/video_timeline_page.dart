import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rantipay_app/core/di/service_container.dart';
import 'package:rantipay_app/core/rantipay/video/application/bloc/timeline_bloc.dart';
import 'package:rantipay_app/core/rantipay/video/application/bloc/timeline_event.dart';
import 'package:rantipay_app/core/rantipay/video/application/bloc/timeline_state.dart';
import 'package:rantipay_app/core/rantipay/video/presentation/widgets/video_post.dart';
import 'package:rantipay_app/core/widgets/loading_spinner.dart';

class VideoTimelinePage extends StatelessWidget {
  static const routeName = '/video-play';
  const VideoTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TimelineBloc>()
        ..add(FetchVideos()), // Cambiamos Cubit a Bloc y el evento FetchVideos
      child: VideoTimelineView(),
    );
  }
}

class VideoTimelineView extends StatefulWidget {
  const VideoTimelineView({super.key});

  @override
  _VideoTimelineViewState createState() => _VideoTimelineViewState();
}

class _VideoTimelineViewState extends State<VideoTimelineView> {
  int _itemCount = 0;
  final PageController _pageController = PageController();
  final Duration _scrollDuration = const Duration(milliseconds: 250);
  final Curve _scrollCurve = Curves.linear;
  int _currentIndex = 0;

  void _onPageChanged(BuildContext context, int page) {
    setState(() {
      _currentIndex = page;
    });

    if (page == _itemCount - 1) {
      context
          .read<TimelineBloc>()
          .add(FetchNextPage()); // Usamos el evento FetchNextPage
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    context
        .read<TimelineBloc>()
        .add(RefreshTimeline()); // Usamos el evento RefreshTimeline
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, TimelineState>(
      // Cambiamos Cubit a Bloc
      builder: (context, state) {
        if (state is TimelineLoading) {
          return const Center(
            child: LoadingSpinner(),
          );
        } else if (state is TimelineError) {
          return Center(
            child: Text(
              'Could not load videos: ${state.message}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (state is TimelineLoaded) {
          _itemCount = state.videos.length;

          return RefreshIndicator(
            onRefresh: () => _onRefresh(context),
            displacement: 50,
            edgeOffset: 20,
            color: Theme.of(context).primaryColor,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (page) => _onPageChanged(context, page),
              itemCount: state.videos.length,
              itemBuilder: (context, index) {
                final videoData = state.videos[index];
                return VideoPost(
                  onVideoFinished: () {
                    _pageController.nextPage(
                      duration: _scrollDuration,
                      curve: _scrollCurve,
                    );
                  },
                  index: index,
                  videoData: videoData,
                  isPlaying: index == _currentIndex,
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}
