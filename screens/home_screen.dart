import 'package:flutter/material.dart';
import 'watchlist_screen.dart';
import 'stock_details_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Stock Data Placeholder'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchlistScreen()),
              );
            },
            child: Text('Go to Watchlist'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockDetailsScreen()),
              );
            },
            child: Text('View Stock Details'),
          ),
        ],
      ),
    );
  }
}
