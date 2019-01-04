import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:the_doghouse/model.dart';

class DogCache extends InheritedWidget {
  DogCache({Key key, @required List<Doggo> dogList, @required Widget child})
      : doggoLookup = dogList.fold(
            <int, Doggo>{},
            (Map<int, Doggo> map, Doggo dog) =>
                map..[dog.id] = dog);
  final Map<int, Doggo> doggoLookup;
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  Doggo urlToDog(String url) {
    // TODO actually parse url to get id.
    var id = 3;
    return doggoLookup[id];
  }
}

class AdoptableDoggos {
  static Future<List<Doggo>> fetchDoggos() async {
    var response = await http.get(
        'https://ra-api.adoptapet.com/v1/pets/featured?location=32830&type=dog-adoption');
    Map json = jsonDecode(response.body);
    var list = Response.fromJson(json);
    return list.body;
  }
}
