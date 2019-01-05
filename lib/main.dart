import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:the_doghouse/data.dart';
import 'package:the_doghouse/model.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  List<Doggo> dogs = await AdoptableDoggos.fetchDoggos();
  return runApp(ScopedModel<DogFavorites>(
      model: DogFavorites(dogs), child: MaterialApp(
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
      leading: const Icon(FontAwesomeIcons.paw),
      title: Text('${dog.name}: ${dog.breeds.primaryBreedName}'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              _dogImage(dog),
              _dogDescription(dog, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dogImage(Doggo dog) {
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
          print('pressed');
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

class FullDogView extends StatefulWidget {
  FullDogView({this.dog});

  final Doggo dog;

  @override
  _FullDogViewState createState() => _FullDogViewState();
}

class _FullDogViewState extends State<FullDogView> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const Icon(FontAwesomeIcons.bone),
            // TODO: use some kind of box instead of Padding Widget
            const Padding(padding: EdgeInsets.only(left: 20.0)),
            const Text('Dog Stats', style: headerStyle),
          ],
        ),
        actions: <Widget>[
          // TODO(efortuna): make this not a dropdown and just an icon?
          Menu(_controller.future),
        ],
      ),
      body: WebView(
        initialUrl: DogFavorites.dogUrl(widget.dog.id),
        javaScriptMode: JavaScriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
      floatingActionButton: _bookmarkButton(),
    );
  }

  _bookmarkButton() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: () async {
              var url = await controller.data.currentUrl();
              final model = ScopedModel.of<DogFavorites>(context);
              model.favorites.add(model.urlToDog(url));
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Favorited ${widget.dog.name}!')),
              );
            },
            child: const Icon(Icons.favorite),
          );
        }
        return Container();
      },
    );
  }
}

class Menu extends StatelessWidget {
  Menu(this._webViewControllerFuture);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (!controller.hasData) return Container();
        return PopupMenuButton<String>(
          onSelected: (String value) async {
            if (value == 'Email link') {
              var url = await controller.data.currentUrl();
              await launch(
                  'mailto:?subject=Can we adopt this doggie&body=$url');
            } else {
              var newId = await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return FavoritesPage();
              }));
              Scaffold.of(context).removeCurrentSnackBar();
              if (newId != null) {
                controller.data.loadUrl(DogFavorites.dogUrl(newId));
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                const PopupMenuItem<String>(
                  value: 'Email link',
                  child: Text('Email link'),
                ),
                const PopupMenuItem<String>(
                  value: 'See Favorites',
                  child: Text('See Favorites'),
                ),
              ],
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
      body: ListView(
          children: ScopedModel.of<DogFavorites>(context)
              .favorites
              .map((dog) => ListTile(
                  // TODO: add picture, too.
                  title: Text(dog.name),
                  onTap: () => Navigator.pop(context, dog.id)))
              .toList()),
    );
  }
}
