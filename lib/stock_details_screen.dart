import 'package:flutter/material.dart';
import 'api_client.dart';

class StockDetailsScreen extends StatelessWidget {
  final String stockSymbol;
  final finnhubClient = FinnhubApiClient();

  StockDetailsScreen({required this.stockSymbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details: $stockSymbol"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: finnhubClient.fetchStockQuote(stockSymbol),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading details: ${snapshot.error}"));
          } else {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stock: $stockSymbol",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text("Current Price: \$${data['c']}"),
                  Text("High: \$${data['h']}"),
                  Text("Low: \$${data['l']}"),
                  Text("Open: \$${data['o']}"),
                  Text("Previous Close: \$${data['pc']}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
