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
        backgroundColor: Colors.green[800],
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
              return Center(
                child: Text(
                  "No stocks in your watchlist.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            } else {
              return ListView(
                children: snapshot.data!.map((stock) {
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
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, stock),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StockDetailsScreen(stockSymbol: stock),
                                ),
                              );
                            },
                          ),
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
        backgroundColor: Colors.green[800],
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

  void _confirmDelete(BuildContext context, String stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $stock from your watchlist?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await dbHelper.removeFromWatchlist(userId, stock);
              Navigator.pop(context); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$stock removed from watchlist")),
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
