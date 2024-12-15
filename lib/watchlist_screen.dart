import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'api_client.dart';
import 'stock_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  final String userId;
  final dbHelper = DatabaseHelper();
  final finnhubClient = FinnhubApiClient();

  WatchlistScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Watchlist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<String>>(
          stream: dbHelper.watchlistStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No stocks in your watchlist."));
            } else {
              return ListView(
                children: snapshot.data!.map((stock) {
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailsScreen(stockSymbol: stock),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addStockToWatchlist(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addStockToWatchlist(BuildContext context) {
    final TextEditingController stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Stock"),
        content: TextField(
          controller: stockController,
          decoration: InputDecoration(labelText: "Stock Symbol"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String stockSymbol = stockController.text.trim();
              if (stockSymbol.isNotEmpty) {
                await dbHelper.addToWatchlist(userId, stockSymbol);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$stockSymbol added to watchlist")),
                );
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
