// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response((json['body'] as List)
      ?.map((e) => e == null ? null : Doggo.fromJson(e as Map<String, dynamic>))
      ?.toList());
}

Map<String, dynamic> _$ResponseToJson(Response instance) =>
    <String, dynamic>{'body': instance.body};

Doggo _$DoggoFromJson(Map<String, dynamic> json) {
  return Doggo(
      json['name'] as String,
      json['petId'] as int,
      json['breeds'] == null
          ? null
          : Breeds.fromJson(json['breeds'] as Map<String, dynamic>),
      json['media'] == null
          ? null
          : Media.fromJson(json['media'] as Map<String, dynamic>),
      json['age'] as String,
      json['sex'] as String);
}

Map<String, dynamic> _$DoggoToJson(Doggo instance) => <String, dynamic>{
      'petId': instance.id,
      'name': instance.name,
      'breeds': instance.breeds,
      'media': instance.media,
      'age': instance.age,
      'sex': instance.gender
    };

Breeds _$BreedsFromJson(Map<String, dynamic> json) {
  return Breeds(
      json['primaryBreedName'] as String, json['secondaryBreedName'] as String);
}

Map<String, dynamic> _$BreedsToJson(Breeds instance) => <String, dynamic>{
      'primaryBreedName': instance.primaryBreedName,
      'secondaryBreedName': instance.secondaryBreedName
    };

Media _$MediaFromJson(Map<String, dynamic> json) {
  return Media((json['images'] as List)
      ?.map((e) =>
          e == null ? null : ImageUrl.fromJson(e as Map<String, dynamic>))
      ?.toList());
}

Map<String, dynamic> _$MediaToJson(Media instance) =>
    <String, dynamic>{'images': instance.images};

ImageUrl _$ImageUrlFromJson(Map<String, dynamic> json) {
  return ImageUrl(json['url'] as String);
}

Map<String, dynamic> _$ImageUrlToJson(ImageUrl instance) =>
    <String, dynamic>{'url': instance.url};
