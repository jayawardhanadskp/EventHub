
import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _showDownloadPopup(context);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onLongPress: () {
          _showDownloadPopup(context);
        },
        child: Center(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  void _showDownloadPopup(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, MediaQuery.of(context).size.height, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.download),
            title: Text('Download Image'),
            onTap: () {

              print('Download Image: $imageUrl');
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
