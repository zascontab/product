import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/rantipay/video/domain/video_entity.dart';



@injectable
class VideosRepositoryImpl {
  final Dio _dio;

  //final String apiKey;

  VideosRepositoryImpl(
    this._dio,
  ) {
    _dio.options.headers['Authorization'] =
        "n7wyEgd5mhvx0kLGZ070X2U3GSOH1Y7CeofqU3OgqE6cqxWV7CqZgSPT";
  }

  Future<List<VideoEntity>> fetchVideos({int? lastItemCreatedAt}) async {
    try {
      final response = await _dio.get(
        'https://api.pexels.com/videos/search',
        queryParameters: {
          'query': 'eggs',
          'per_page': 20, // Número de videos por solicitud
          'page': (lastItemCreatedAt ??
              1), // Usar lastItemCreatedAt como número de página
        },
      );
      final data = jsonDecode(response.toString()) as Map<String, dynamic>;
      print(
          'Response data: $data'); // Imprime la respuesta completa para ver la estructura

      final videosData = data['videos'] as List;

      // Asegúrate de que la respuesta sea un Map<String, dynamic>

      final List<VideoEntity> videos = [];
      for (var json in videosData) {
        try {
          // Verifica que json['video_files'] es una lista y contiene al menos un elemento
          if (json['video_files'] is List &&
              (json['video_files'] as List).isNotEmpty) {
            final List<VideoResolution> videoFiles =
                (json['video_files'] as List)
                    .map((videoFileJson) => VideoResolution.fromJson(
                        videoFileJson as Map<String, dynamic>))
                    .toList();

            final video = VideoEntity(
              id: json['id'].toString(),
              title:
                  'videos', // Pexels no proporciona título, así que dejamos en blanco
              description:
                  'Videos de pruebas', // Pexels no proporciona descripción, así que dejamos en blanco
              fileUrl: videoFiles.first
                  .link, // Usar el primer video como archivo predeterminado
              thumbnailUrl: json['image'],
              creatorUid: json['user']['id'].toString(), // Convierto a String
              creator: json['user']['name'],
              likes: json['liked'] == true
                  ? 1
                  : 0, // Verificar si 'liked' es verdadero
              comments:
                  0, // Placeholder ya que Pexels no proporciona comentarios
              createdAt: DateTime.now().millisecondsSinceEpoch,
              videoFiles: videoFiles,
            );
            videos.add(video);
          } else {
            throw Exception('Invalid video_files data');
          }
        } catch (e) {
          print('Error parsing video JSON: $json\nError: $e');
          // O manejar el error según sea necesario
        }
      }

      return videos;
    } catch (e) {
      print('Error fetching videos: $e');
      rethrow;
    }
  }

  Future<List<VideoEntity>> fetchVideosXX({int? lastItemCreatedAt}) async {
    try {
      final response = await _dio.get(
        'https://api.pexels.com/videos/popular',
        queryParameters: {
          'per_page': 10, // Number of videos to fetch per request
          'page':
              (lastItemCreatedAt ?? 1), // Use lastItemCreatedAt as page number
        },
      );

      final videos = (response.data['videos'] as List)
          .map((json) => VideoEntity.fromJson({
                'id': json['id'],
                'url': json['video_files'][0]['link'],
                'thumbnailUrl': json['image'],
                'creator': json['user']['name'],
                'likes': json['liked'] is int
                    ? 1
                    : 0, // Pexels does not provide likes count
                'comments':
                    0, // Placeholder as Pexels does not provide comments
                'createdAt': DateTime.now().millisecondsSinceEpoch,
              }))
          .toList();

      return videos;
    } catch (e) {
      print('Error fetching videos: $e');
      rethrow;
    }
  }
/*   Future<List<VideoEntity>> fetchVideos({int? lastItemCreatedAt}) async {
    try {
      final response = await _dio.get('/videos', queryParameters: {
        'lastItemCreatedAt': lastItemCreatedAt,
      });

      final videos = (response.data as List)
          .map((json) => VideoEntity.fromJson(json))
          .toList();

      return videos;
    } catch (e, stackTrace) {
      print('Error fetching videos: $e');
      throw e;
    }
  } */

  Future<void> saveVideo(Map<String, dynamic> videoData) async {
    try {
      FormData formData = FormData.fromMap(videoData);
      await _dio.post('/upload', data: formData);
    } catch (e) {
      print('Error saving video: $e');
      rethrow;
    }
  }

  Future<void> likeVideo(String videoId, String userId) async {
    try {
      await _dio.post('/videos/$videoId/like', data: {'userId': userId});
    } catch (e) {
      print('Error liking video: $e');
      rethrow;
    }
  }

  Future<bool> isLiked(String videoId, String userId) async {
    try {
      final response = await _dio
          .get('/videos/$videoId/isLiked', queryParameters: {'userId': userId});
      return response.data['isLiked'] as bool;
    } catch (e) {
      print('Error checking if video is liked: $e');
      rethrow;
    }
  }
}
