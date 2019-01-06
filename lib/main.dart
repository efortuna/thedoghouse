import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_future_builder/simple_future_builder.dart';
import 'package:the_doghouse/data.dart';
import 'package:the_doghouse/model.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  List<Doggo> dogs = await AdoptableDoggos.fetchDoggos();
  return runApp(ScopedModel<DogFavorites>(
    model: DogFavorites(dogs),
    child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.brown,
          accentColor: Colors.deepOrange,
          fontFamily: 'HappyMonkey',
        ),
        home: DogList()),
  ));
}

const headerStyle = TextStyle(fontFamily: 'FingerPaint');

class DogList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Who's in the dog house?", style: headerStyle),
        leading: const Icon(FontAwesomeIcons.dog),
      ),
      body: ListView(
        children: ScopedModel.of<DogFavorites>(context)
            .dogList
            .map((dog) => _buildItem(dog, context))
            .toList(),
      ),
    );
  }

  Widget _buildItem(Doggo dog, BuildContext context) {
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

class FullDogView extends StatefulWidget {
  FullDogView({this.dog});

  final Doggo dog;

  @override
  _FullDogViewState createState() => _FullDogViewState();
}

class _FullDogViewState extends State<FullDogView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const Icon(FontAwesomeIcons.bone),
            const Padding(padding: EdgeInsets.only(left: 20.0)),
            const Text('Dog Stats', style: headerStyle),
          ],
        ),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  Menu(this._webViewControllerFuture);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder(
      future: _webViewControllerFuture,
      builder: (BuildContext context, WebViewController controller) {
        return PopupMenuButton<String>(
          itemBuilder: (BuildContext context) {},
          onSelected: (String value) async {},
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite dogs')),
    );
  }
}
