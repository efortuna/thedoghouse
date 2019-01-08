import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:the_doghouse/webview.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:the_doghouse/data/data.dart';
import 'package:the_doghouse/data/model.dart';

void main() async {
  List<Doggo> dogs = await AdoptableDoggos.fetchDoggos();
  return runApp(ScopedModel<AdoptableDoggos>(
    model: AdoptableDoggos(dogs),
    child: MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.brown,
        accentColor: Colors.deepOrange,
        fontFamily: 'HappyMonkey',
      ),
      home: DogList(),
    ),
  ));
}

const headerStyle = TextStyle(fontFamily: 'FingerPaint');

class DogList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Who's in the dog house?", style: headerStyle),
      ),
      body: ListView(children: <Widget>[],
      ),
    );
  }
}

class DogTile extends StatelessWidget {
  DogTile(this.dog);
  final Doggo dog;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('${dog.name}: ${dog.breeds.primaryBreedName}'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              _dogDescription(dog, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dogDescription(Doggo dog, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Age: ${dog.age}'),
        Text('Gender: ${dog.gender}'),
        _buttonOpenWebView(context, dog)
      ],
    );
  }

  Widget _buttonOpenWebView(BuildContext context, Doggo dog) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: RaisedButton(
        child: Text('Learn more about me!'),
        onPressed: () {},
      ),
    );
  }
}

class DogImage extends StatelessWidget {
  DogImage(this.dog);

  final Doggo dog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 120.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: dog.media.images.first.url,
          ),
        ),
      ),
    );
  }
}