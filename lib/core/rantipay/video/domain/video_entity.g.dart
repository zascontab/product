// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoEntityImpl _$$VideoEntityImplFromJson(Map<String, dynamic> json) =>
    _$VideoEntityImpl(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fileUrl: json['fileUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      creatorUid: json['creatorUid'] as String? ?? '',
      creator: json['creator'] as String,
      likes: (json['likes'] as num).toInt(),
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] as num).toInt(),
      videoFiles: (json['videoFiles'] as List<dynamic>)
          .map((e) => VideoResolution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$VideoEntityImplToJson(_$VideoEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'fileUrl': instance.fileUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'creatorUid': instance.creatorUid,
      'creator': instance.creator,
      'likes': instance.likes,
      'comments': instance.comments,
      'createdAt': instance.createdAt,
      'videoFiles': instance.videoFiles,
    };

_$VideoResolutionImpl _$$VideoResolutionImplFromJson(
        Map<String, dynamic> json) =>
    _$VideoResolutionImpl(
      id: (json['id'] as num).toInt(),
      quality: json['quality'] as String,
      fileType: json['file_type'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      fps: (json['fps'] as num).toDouble(),
      link: json['link'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$$VideoResolutionImplToJson(
        _$VideoResolutionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quality': instance.quality,
      'file_type': instance.fileType,
      'width': instance.width,
      'height': instance.height,
      'fps': instance.fps,
      'link': instance.link,
      'size': instance.size,
    };
