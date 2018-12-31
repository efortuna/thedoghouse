import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Response {
  final List<Doggo> body;

  Response(this.body);

  factory Response.fromJson(Map<String, dynamic> json) => _$ResponseFromJson(json);
}

@JsonSerializable()
class Doggo {

  @JsonKey(name: "petId")
  final int id;
  final String name;
//  final String description;

  Doggo(this.name, this.id);

  factory Doggo.fromJson(Map<String, dynamic> json) => _$DoggoFromJson(json);
}

//class Breed {}
