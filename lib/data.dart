import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class Doggo {
  Doggo(this.name, this.detailsUrl);
  final String detailsUrl;
  final String name;
}

class Doggos {
  Doggos() : _stream = AdoptableDoggos() {
    _subject.addStream(_stream);
  }
  // Use BehaviorSubject so we can always get the latest set of dogs,
  // even if there haven't been any new additions.
  final _subject = BehaviorSubject<List<Doggo>>();
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
    // Or http://www.dogsblog.com/feed/
    var response = await http.get('http://www.dogsonly.org/feed.xml');
    // TODO: error checking.
    //var doc = xml.parse(response.body);
    //TODO actual data!
    var list = List.generate(10, (_) => Doggo('Fido', 'https://www.adoptapet.com/pet/23665138-seattle-washington-german-shepherd-dog'));
    _controller.add(list);
  }
}
