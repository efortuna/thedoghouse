import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_future_builder/simple_future_builder.dart';
import 'package:the_doghouse/data/data.dart';
import 'package:the_doghouse/data/model.dart';
import 'package:the_doghouse/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FullDogView extends StatelessWidget {
  FullDogView({@required this.dog})
      : _controller = Completer<WebViewController>();

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
      builder: (BuildContext context, _) {
        return FloatingActionButton(
          child: const Icon(Icons.favorite),
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
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Icon(Icons.favorite, color: Colors.deepOrange),
                Text(
                  ScopedModel.of<AdoptableDoggos>(context, rebuildOnChange: true)
                      .favorites
                      .length
                      .toString(),
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          )
        ],
      ),
      onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => FavoritesPage()),
              (route) => route.isFirst),
    );
  }
}
