import 'package:dio/dio.dart';

class AlphaVantageApi {
  final Dio _dio;
  static const String _baseUrl = 'https://www.alphavantage.co/query';
  final String _apiKey = 'UW68ZMJAEQ4TFJZ9';

  AlphaVantageApi(this._dio);

  Future<double> getCurrentPrice(String symbol) async {
    if (_apiKey == 'YOUR_KEY' || _apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockPrice(symbol);
    }

    try {
      final response = await _dio.get(_baseUrl, queryParameters: {
        'function': 'GLOBAL_QUOTE',
        'symbol': symbol,
        'apikey': _apiKey,
      });

      if (response.data != null && response.data['Global Quote'] != null) {
        final quote = response.data['Global Quote'];
        return double.tryParse(quote['05. price'].toString()) ?? _getMockPrice(symbol);
      }
      return _getMockPrice(symbol);
    } catch (e) {
      return _getMockPrice(symbol);
    }
  }

  Future<double> getDailyChangePercent(String symbol) async {
    if (_apiKey == 'YOUR_KEY' || _apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _getMockChange(symbol);
    }

    try {
      final response = await _dio.get(_baseUrl, queryParameters: {
        'function': 'GLOBAL_QUOTE',
        'symbol': symbol,
        'apikey': _apiKey,
      });

      if (response.data != null && response.data['Global Quote'] != null) {
        final quote = response.data['Global Quote'];
        final raw = quote['10. change percent']?.toString().replaceAll('%', '') ?? '0';
        return double.tryParse(raw) ?? _getMockChange(symbol);
      }
      return _getMockChange(symbol);
    } catch (e) {
      return _getMockChange(symbol);
    }
  }

  double _getMockPrice(String symbol) {
    final mockPrices = {
      'AAPL': 175.50,
      'TSLA': 202.10,
      'MSFT': 420.30,
      'GOOGL': 168.40,
      'AMZN': 185.20,
      'NKE': 95.60,
      'SBUX': 85.30,
      'OXY': 65.40,
      'NEE': 70.20,
      'XOM': 110.50,
    };
    return mockPrices[symbol.toUpperCase()] ?? 100.0;
  }

  double _getMockChange(String symbol) {
    final mockChanges = {
      'AAPL': 1.24,
      'TSLA': -2.15,
      'MSFT': 0.87,
      'GOOGL': 1.56,
      'AMZN': -0.42,
      'NKE': 0.33,
      'SBUX': -1.10,
      'OXY': -3.20,
      'NEE': 2.05,
      'XOM': -1.78,
    };
    return mockChanges[symbol.toUpperCase()] ?? 0.0;
  }
}
