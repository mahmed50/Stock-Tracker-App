import 'dart:convert';
import 'package:http/http.dart' as http;

class FinnhubApiClient {
  // Your Finnhub API key
  final String _apiKey = 'ctetm6hr01qngidcnfb0ctetm6hr01qngidcnfbg';
  final String _baseUrl = 'https://finnhub.io/api/v1';


  // Fetch stock quote for a given symbol
  Future<Map<String, dynamic>> fetchStockQuote(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stock data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching stock quote: $e');
    }
  }



  // Fetch company profile for a given symbol
  Future<Map<String, dynamic>> fetchCompanyProfile(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stock/profile2?symbol=$symbol&token=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load company profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching company profile: $e');
    }
  }



  // Fetch news related to a given stock symbol
  Future<List<dynamic>> fetchStockNews(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/news?category=general&symbol=$symbol&token=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stock news: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching stock news: $e');
    }
  }

  
}
