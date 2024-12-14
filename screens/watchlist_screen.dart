import 'package:flutter/material.dart';

class WatchlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watchlist')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Stock 1'),
          ),
          ListTile(
            title: Text('Stock 2'),
          ),
          ListTile(
            title: Text('Stock 3'),
          ),
        ],
      ),
    );
  }
}
