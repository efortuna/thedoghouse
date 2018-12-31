import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_doghouse/data.dart';
import 'package:the_doghouse/model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.brown,
        accentColor: Colors.deepOrange,
        fontFamily: 'IndieFlower',
      ),
      home: DogList(),
    ));

final headerStyle = TextStyle(fontFamily: 'FingerPaint');

class DogList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Who's in the dog house?", style: headerStyle),
        leading: const Icon(FontAwesomeIcons.dog),
      ),
      body: StreamBuilder<List<Doggo>>(
        stream: Doggos().stream,
        initialData: <Doggo>[],
        builder: (context, snapshot) => ListView(
              children:
                  snapshot.data.map((dog) => _buildItem(dog, context)).toList(),
            ),
      ),
    );
  }

  Widget _buildItem(Doggo dog, BuildContext context) {
    return ExpansionTile(
      leading: const Icon(FontAwesomeIcons.paw),
      title: Text(dog.breeds.primaryBreedName),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Image.network(
                dog.media.images.first.url,
                height: 120,
              ),
              Column(
                children: <Widget>[
                  Text('Age: age'),
                  Text('Sex: sex'),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullDogView(
                                  dog: dog,
                                ),
                          ));
                    },
                    child: Row(
                      children: <Widget>[
                        Text('Adopt me!'),
                        Icon(Icons.launch)
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
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
  final Set<String> _favorites = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const Text('Dog Stats'),
            const Icon(FontAwesomeIcons.bone),
          ],
        ),
        actions: <Widget>[
          // TODO(efortuna): make this not a dropdown and just an icon?
          Menu(_controller.future, () => _favorites),
        ],
      ),
      body: WebView(
        initialUrl: widget.dog.id.toString(),
        // TODO(efortuna): This site requres javascript. Other adoption site that doesn't?
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
              _favorites.add(url);
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
                  'mailto:?subject=Check out this cool Wikipedia page&body=$url');
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
      appBar: AppBar(title: Text('Favorite pages')),
      body: ListView(
          children: favorites
              .map((url) => ListTile(
                  title: Text(url), onTap: () => Navigator.pop(context, url)))
              .toList()),
    );
  }
}
