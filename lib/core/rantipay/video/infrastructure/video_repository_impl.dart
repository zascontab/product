import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/rantipay/video/domain/video_entity.dart';
import 'package:rantipay_app/core/rantipay/video/infrastructure/videos_repository_impl.dart';


@injectable
class VideoRepositoryImpl {
  final VideosRepositoryImpl _videosRepository;

  VideoRepositoryImpl(this._videosRepository);

  Future<List<VideoEntity>> fetchVideos({int? lastItemCreatedAt}) async {
    final videos = await _videosRepository.fetchVideos(
        lastItemCreatedAt: lastItemCreatedAt);
    return videos;
  }

  Future<void> uploadVideo(VideoEntity video) async {
    await _videosRepository.saveVideo(video.toJson());
  }

  Future<void> likeVideo(String videoId, String userId) async {
    await _videosRepository.likeVideo(videoId, userId);
  }

  Future<bool> isLiked(String videoId, String userId) async {
    return await _videosRepository.isLiked(videoId, userId);
  }
}
