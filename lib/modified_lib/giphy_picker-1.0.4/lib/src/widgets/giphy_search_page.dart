import 'package:flutter/material.dart';
import 'package:giphy_picker/src/widgets/giphy_search_view.dart';

class GiphySearchPage extends StatelessWidget {
  final Widget title;

  const GiphySearchPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Preview of gifs",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "",
              fontSize: 22.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(child: GiphySearchView(), bottom: false));
  }
}
