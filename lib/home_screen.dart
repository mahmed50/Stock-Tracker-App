import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'api_client.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userId;
  final dbHelper = DatabaseHelper();
  final finnhubClient = FinnhubApiClient();

  HomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final List<String> majorStocks = ['AAPL', 'GOOGL', 'AMZN', 'TSLA', 'MSFT'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await dbHelper.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Major Stocks",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: majorStocks.map((stock) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: finnhubClient.fetchStockQuote(stock),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text(stock),
                          subtitle: Text("Loading..."),
                        );
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text(stock),
                          subtitle: Text("Error loading data"),
                        );
                      } else {
                        final data = snapshot.data!;
                        return ListTile(
                          title: Text(stock),
                          subtitle: Text("Current Price: \$${data['c']}"),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(userId: userId),
                  ),
                );
              },
              child: Text("View Watchlist"),
            ),
          ],
        ),
      ),
    );
  }
}
