import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_future_builder/simple_future_builder.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:the_doghouse/data.dart';
import 'package:the_doghouse/model.dart';

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
        leading: const Icon(FontAwesomeIcons.bone),
        actions: <Widget>[FavoritesButton()],
      ),
      body: ListView(
        children: ScopedModel.of<AdoptableDoggos>(context)
            .dogList
            .map((dog) => DogTile(dog))
            .toList(),
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
      leading: const Icon(FontAwesomeIcons.paw),
      title: Text('${dog.name}: ${dog.breeds.primaryBreedName}'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              DogImage(dog),
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
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullDogView(
                      dog: dog,
                    ),
              ));
        },
        child: Text('Learn more about me!'),
      ),
    );
  }
}

class FullDogView extends StatelessWidget {
  FullDogView({@required this.dog}) : _controller = Completer<WebViewController>();

  final Doggo dog;
  final Completer<WebViewController> _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Stats: ${dog.name}', style: headerStyle),
        actions: <Widget>[FavoritesButton()],
      ),
      body: WebView(
        initialUrl: AdoptableDoggos.dogUrl(dog.id),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
      floatingActionButton: _bookmarkButton(),
    );
  }

  _bookmarkButton() {
    return SimpleFutureBuilder<WebViewController>(
      future: _controller.future,
      builder: (BuildContext context, WebViewController controller) {
        return FloatingActionButton(
          onPressed: () async {
            final model = ScopedModel.of<AdoptableDoggos>(context);
            // Technically the user could have moved away from the original
            // dog but we're going to ignore that because then we might
            // not have url -> dog mapping if it didn't come in our original
            // set.
            model.addFavorite(dog);
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Favorited ${dog.name}!')),
            );
          },
          child: const Icon(Icons.favorite),
        );
      },
    );
  }
}

class FavoritesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
        const Icon(FontAwesomeIcons.dog),
        Positioned(
          top: 10.0,
          right: -10.0,
          child: Material(
              type: MaterialType.circle,
              color: Colors.deepOrange,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  ScopedModel.of<AdoptableDoggos>(context).favorites.length.toString(),
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white,//widget.badgeTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        )
      ],),
      onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => FavoritesPage()),
              (route) => route.isFirst),
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

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite dogs')),
      body: ListView(
          children: ScopedModel.of<AdoptableDoggos>(context)
              .favorites
              .map((dog) => ListTile(
                  title: Row(
                    children: <Widget>[DogImage(dog), Text(dog.name)],
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullDogView(dog: dog),
                      ))))
              .toList()),
    );
  }
}
