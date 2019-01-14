import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:the_doghouse/data/model.dart';
import 'package:scoped_model/scoped_model.dart';

class AdoptableDoggos extends Model {
  AdoptableDoggos(this.dogList) : _favorites = Set<Doggo>();
  final Set<Doggo> _favorites;
  final List<Doggo> dogList;

  Set<Doggo> get favorites => _favorites;

  addFavorite(Doggo dog) {
    _favorites.add(dog);
    notifyListeners();
  }

  static String dogUrl(int id) => 'https://adoptapet.com/pet/$id';

  static Future<List<Doggo>> fetchDoggos() async {
    var response = await http.get(
        'https://ra-api.adoptapet.com/v1/pets/featured?location=32830&type=dog-adoption');
    Map json = jsonDecode(response.body);
    // Fallback in case things go horribly wrong.
    //var offlineData =
    //    '{"meta":{"resource":"/v1/pets/featured?location=32830&type=dog-adoption","version":"1.0.0","time":"639ms"},"body":[{"age":"young","breeds":{"purebred":false,"primaryBreedId":823,"secondaryBreedId":200,"primaryBreedName":"Labrador Retriever","secondaryBreedName":"Mastiff"},"clanId":1,"colorId":47,"createdDate":"2018-08-07T17:52:40.296176","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/8/6/7/352852672.jpg","height":250,"width":250,"tag":"h"}]},"name":"Oppi","petId":22805193,"radius":4,"sex":"m","shelterId":82766,"shots":true,"sizeId":2,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":823,"secondaryBreedId":33,"primaryBreedName":"Labrador Retriever","secondaryBreedName":"Catahoula Leopard Dog"},"clanId":1,"colorId":47,"createdDate":"2018-11-08T17:00:08.420918","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/5/f/b/372076426.jpg","height":250,"width":250,"tag":"h"}]},"name":"Santa paws","petId":23736966,"radius":7,"sex":"m","shelterId":104146,"shots":true,"sizeId":2,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":57,"secondaryBreedId":823,"primaryBreedName":"German Shepherd Dog","secondaryBreedName":"Labrador Retriever"},"clanId":1,"colorId":84,"createdDate":"2018-12-07T12:59:13.90564","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/1/c/5/377909667.jpg","height":250,"width":250,"tag":"h"}]},"name":"Dash","petId":23995915,"radius":7,"sex":"m","shelterId":104146,"shots":true,"sizeId":3,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":823,"secondaryBreedId":804,"primaryBreedName":"Labrador Retriever","secondaryBreedName":"Black Mouth Cur"},"clanId":1,"colorId":45,"createdDate":"2018-12-14T12:19:47.768942","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/e/7/a/379423413.jpg","height":250,"width":250,"tag":"h"}]},"name":"Lab pups","petId":24066497,"radius":7,"sex":"m","shelterId":104146,"shots":true,"sizeId":2,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":70,"secondaryBreedId":36,"primaryBreedName":"Jack Russell Terrier","secondaryBreedName":"Chihuahua"},"clanId":1,"colorId":61,"createdDate":"2018-12-14T12:32:42.512203","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/a/e/0/379425796.jpg","height":250,"width":250,"tag":"h"}]},"name":"Lil Reindeer","petId":24066621,"radius":7,"sex":"f","shelterId":104146,"shots":true,"sizeId":1,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":99,"secondaryBreedId":null,"primaryBreedName":"Rottweiler"},"clanId":1,"colorId":74,"createdDate":"2018-12-17T00:14:05.228211","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/6/6/f/379896954.jpg","height":250,"width":250,"tag":"h"}]},"name":"Rocky","petId":24086441,"radius":7,"sex":"m","shelterId":104146,"shots":true,"sizeId":2,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":823,"secondaryBreedId":null,"primaryBreedName":"Labrador Retriever"},"clanId":1,"colorId":45,"createdDate":"2018-12-17T00:24:28.048955","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/5/7/f/379897783.jpg","height":250,"width":250,"tag":"h"}]},"name":"Labby","petId":24086452,"radius":7,"sex":"m","shelterId":104146,"shots":true,"sizeId":2,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":57,"secondaryBreedId":1084,"primaryBreedName":"German Shepherd Dog","secondaryBreedName":"Siberian Husky"},"clanId":1,"colorId":92,"createdDate":"2018-12-17T07:29:33.014246","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/6/c/7/379943673.jpg","height":250,"width":250,"tag":"h"}]},"name":"Holly","petId":24087530,"radius":7,"sex":"f","shelterId":104146,"shots":true,"sizeId":3,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"},{"age":"puppy","breeds":{"purebred":false,"primaryBreedId":57,"secondaryBreedId":null,"primaryBreedName":"German Shepherd Dog"},"clanId":1,"colorId":74,"createdDate":"2018-12-19T08:03:23.921754","media":{"images":[{"url":"https://pet-uploads.adoptapet.com/0/a/4/380449119.jpg","height":250,"width":250,"tag":"h"}]},"name":"Shiloh","petId":24107123,"radius":7,"sex":"f","shelterId":104146,"shots":true,"sizeId":3,"specialNeeds":false,"bondedTo":null,"city":"Orlando","state":"FL","actQuickly":false,"stateName":"Florida"}]}';
    //Map json = jsonDecode(offlineData);
    var list = Response.fromJson(json);
    list.body.forEach((Doggo d) => _dogLookup[d.id] = d);
    return list.body;
  }

  static final Map<int, Doggo> _dogLookup = Map<int, Doggo>();

  /// Try to find the corresponding Dog based on the source URL. If we encounter
  /// an error while parsing, return null.
  static Doggo urlToDog(String url) {
    try {
      var str = url.substring(url.lastIndexOf('/') + 1);
      if (str.indexOf('-') != -1) str = str.substring(0, str.indexOf('-'));
      return _dogLookup[int.parse(str)];
    } catch (e) {
      return null;
    }
  }
}

