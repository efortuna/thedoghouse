import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:the_doghouse/data.dart';
import 'package:the_doghouse/model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_future_builder/simple_future_builder.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.brown,
        accentColor: Colors.deepOrange,
        fontFamily: 'HappyMonkey',
      ),
      home: DogList(),
    ));

const headerStyle = TextStyle(fontFamily: 'FingerPaint');

class DogList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Who's in the dog house?", style: headerStyle),
        leading: const Icon(FontAwesomeIcons.dog),
      ),
      body: SimpleFutureBuilder<List<Doggo>>(
        future: AdoptableDoggos.fetchDoggos(),
        builder: (context, data) => DogCache(
            dogList: data,
            child: ListView(
              children: data.map((dog) => _buildItem(dog, context)).toList(),
            )),
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

class DogFavorites extends Model {
  Set<Doggo> _favorites;
  DogFavorites(this._favorites);
  // TODO: convert URL to dog info...

  add(Doggo dog) {
    _favorites.add(dog);
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
          Menu(_controller.future, () => _favorites),
        ],
      ),
      body: WebView(
        initialUrl: _dogUrl(),
        // TODO(efortuna): This site requres javascript. Other adoption site that doesn't?
        javaScriptMode: JavaScriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
      floatingActionButton: _bookmarkButton(),
    );
  }

  String _dogUrl() => 'https://adoptapet.com/pet/${widget.dog.id}';

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
              final model =
                  ScopedModel.of<DogFavorites>(context, rebuildOnChange: false);
              // TODO: does Doggos need to become an inheritedWidget to access here?
              model.add(urlToDoggo(url));
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
  Menu(this._webViewControllerFuture, this.favoritesAccessor);

  final Future<WebViewController> _webViewControllerFuture;

  // TODO(efortuna): Come up with a more elegant solution for an accessor to this than a callback.
  // This should be state stuff.
  final Function favoritesAccessor;

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
              var newUrl = await Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return FavoritesPage(favoritesAccessor());
              }));
              Scaffold.of(context).removeCurrentSnackBar();
              if (newUrl != null) controller.data.loadUrl(newUrl);
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
  FavoritesPage(this.favorites);

  final Set<String> favorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite dogs')),
      body: ListView(
          children: favorites
              .map((url) => ListTile(
                  title: Text(url), onTap: () => Navigator.pop(context, url)))
              .toList()),
    );
  }
}
