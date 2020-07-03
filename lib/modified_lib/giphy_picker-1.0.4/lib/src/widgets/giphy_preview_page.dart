import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:giphy_picker/src/widgets/giphy_image.dart';

/// Presents a Giphy preview image.
class GiphyPreviewPage extends StatelessWidget {
  final GiphyGif gif;
  final Widget title;
  final ValueChanged<GiphyGif> onSelected;

  const GiphyPreviewPage(
      {@required this.gif, @required this.onSelected, this.title});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Image.asset(
                'assets/icons/back.png',
                width: 30,
                height: 30,
              ),
            ),
            title: Text(
              "Preview of gifs",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "",
                fontSize: 22.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: <Widget>[
              FlatButton(
                  onPressed: () => onSelected(gif),
                  child: Icon(Icons.done_outline)),
            ]),
        body: SafeArea(
            child: Center(
                child: GiphyImage.original(
              gif: gif,
              width: media.orientation == Orientation.portrait
                  ? double.maxFinite
                  : null,
              height: media.orientation == Orientation.landscape
                  ? double.maxFinite
                  : null,
              fit: BoxFit.contain,
            )),
            bottom: false));
  }
}
