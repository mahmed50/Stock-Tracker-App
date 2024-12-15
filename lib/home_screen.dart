import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'api_client.dart';
import 'stock_details_screen.dart';
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
        backgroundColor: Colors.green[800],
        title: Text(
          "Stock Tracker",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: majorStocks.map((stock) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: finnhubClient.fetchStockQuote(stock),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(stock),
                            subtitle: Text("Loading..."),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(stock),
                            subtitle: Text("Error loading data"),
                          ),
                        );
                      } else {
                        final data = snapshot.data!;
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              stock,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Current Price: \$${data['c']}",
                              style: TextStyle(color: Colors.green[700]),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StockDetailsScreen(stockSymbol: stock),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 165, 212, 168),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(userId: userId),
                  ),
                );
              },
              child: Text(
                "View Watchlist",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
