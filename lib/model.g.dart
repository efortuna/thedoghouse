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
  return Doggo(json['name'] as String, json['petId'] as int);
}

Map<String, dynamic> _$DoggoToJson(Doggo instance) =>
    <String, dynamic>{'petId': instance.id, 'name': instance.name};
