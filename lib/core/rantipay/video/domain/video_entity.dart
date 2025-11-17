import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_entity.freezed.dart';
part 'video_entity.g.dart';

@freezed
class VideoEntity with _$VideoEntity {
  const factory VideoEntity({
    required String id,
    @Default('') String title,
    @Default('') String description,
    required String fileUrl,
    required String thumbnailUrl,
    @Default('') String creatorUid,
    required String creator,
    required int likes,
    @Default(0) int comments,
    required int createdAt,
    required List<VideoResolution>
        videoFiles, // Añadido para las resoluciones de video
  }) = _VideoEntity;

  factory VideoEntity.fromJson(Map<String, dynamic> json) =>
      _$VideoEntityFromJson(json);
}

@freezed
class VideoResolution with _$VideoResolution {
  const factory VideoResolution({
    required int id,
    required String quality,
    @JsonKey(name: 'file_type') required String fileType,
    required int width,
    required int height,
    required double fps,
    required String link,
    required int size,
  }) = _VideoResolution;

  factory VideoResolution.fromJson(Map<String, dynamic> json) =>
      _$VideoResolutionFromJson(json);
}

extension VideoEntityX on VideoEntity {
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'fileUrl': fileUrl,
        'thumbnailUrl': thumbnailUrl,
        'creatorUid': creatorUid,
        'creator': creator,
        'likes': likes,
        'comments': comments,
        'createdAt': createdAt,
        'videoFiles': videoFiles.map((res) => res.toJson()).toList(),
      };
}
