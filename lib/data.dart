import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:the_doghouse/model.dart';

class Doggos {
  Doggos() : _stream = AdoptableDoggos() {
    _subject.addStream(_stream);
  }
  // Use BehaviorSubject so we can always get the latest set of dogs,
  // even if there haven't been any new additions.
  final _subject = BehaviorSubject<List<Doggo>>(seedValue: <Doggo>[]);
  final AdoptableDoggos _stream;
  Stream<List<Doggo>> get stream => _subject.stream;
}

class AdoptableDoggos extends Stream<List<Doggo>> {
  // TODO(efortuna): food for thought... make this just a future? technically we just get stuff each time.
  StreamController<List<Doggo>> _controller = new StreamController.broadcast();

  @override
  StreamSubscription<List<Doggo>> listen(
      void Function(List<Doggo> event) onData,
      {Function onError,
      void Function() onDone,
      bool cancelOnError}) {
    _fetchDoggos();
    return _controller.stream.listen(onData);
  }

  _fetchDoggos() async {
    var response = await http.get('https://ra-api.adoptapet.com/v1/pets/featured?location=32830&type=dog-adoption');
    Map json = jsonDecode(response.body);
    var list = Response.fromJson(json);
    _controller.add(list.body);
  }
}
