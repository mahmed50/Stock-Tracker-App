import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
        backgroundColor: Colors.green[800],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCombinedData(stockSymbol),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading details: ${snapshot.error}"));
          } else {
            final data = snapshot.data!;
            final profileData = data['profile'];
            final quoteData = data['quote'];
            final graphData = generateSyntheticGraphData(quoteData['c']);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Profile Section
                    Row(
                      children: [
                        if (profileData['logo'] != null)
                          Image.network(
                            profileData['logo'],
                            height: 50,
                            width: 50,
                          ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileData['name'] ?? stockSymbol,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                profileData['industry'] ?? "Industry: Not available",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                       SizedBox(height: 10),                   
                    Text(
                      "Description: ${profileData['description'] ?? "No Data Available"}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),

                    // Stock Quote Section
                    Text(
                      "Stock Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("Current Price: \$${quoteData['c']}"),
                    Text("High: \$${quoteData['h']}"),
                    Text("Low: \$${quoteData['l']}"),
                    Text("Open: \$${quoteData['o']}"),
                    Text("Previous Close: \$${quoteData['pc']}"),
                    SizedBox(height: 20),

                    // Chart Section
                    Text(
                      "Price Trend",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        primaryXAxis: NumericAxis(),
                        primaryYAxis: NumericAxis(labelFormat: '\${value}'),
                        series: <LineSeries<GraphData, int>>[
                          LineSeries<GraphData, int>(
                            dataSource: graphData,
                            xValueMapper: (data, _) => data.x,
                            yValueMapper: (data, _) => data.y,
                            name: 'Price',
                            color: Colors.green,
                            markerSettings: MarkerSettings(isVisible: true),
                          ),
                        ],
                        title: ChartTitle(text: 'Synthetic Price Trend'),
                        legend: Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Fetch both the company profile and stock quote
  Future<Map<String, dynamic>> _fetchCombinedData(String stockSymbol) async {
    final profile = await finnhubClient.fetchCompanyProfile(stockSymbol);
    final quote = await finnhubClient.fetchStockQuote(stockSymbol);

    return {
      'profile': profile,
      'quote': quote,
    };
  }

  // Generate synthetic data for the graph
  List<GraphData> generateSyntheticGraphData(double currentPrice) {
    return List<GraphData>.generate(10, (index) {
      final randomChange = (index - 5) * (currentPrice * 0.01); // 1% fluctuation
      return GraphData(x: index, y: currentPrice + randomChange);
    });
  }
}

class GraphData {
  final int x;
  final double y;

  GraphData({required this.x, required this.y});
}
