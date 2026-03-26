import 'package:dio/dio.dart';
import '../../../domain/entities/esg_data.dart';

class ESGApi {
  final Dio _dio;

  ESGApi(this._dio);

  Future<ESGData> getESGData(String symbol) async {
    // In a real scenario, this would call an API like OpenESG or ESG Enterprise
    // Since we don't have direct access here, we implement a comprehensive mock delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final upperSymbol = symbol.toUpperCase();
    final mockESGDatabase = {
      'AAPL': ESGData(symbol: 'AAPL', esgScore: 75.0, carbonEmissions: 15.2, historicalEmissions: [18.5, 17.2, 16.0, 15.8, 15.2]),
      'TSLA': ESGData(symbol: 'TSLA', esgScore: 82.5, carbonEmissions: 2.1, historicalEmissions: [3.5, 3.0, 2.8, 2.5, 2.1]),
      'MSFT': ESGData(symbol: 'MSFT', esgScore: 88.0, carbonEmissions: 5.4, historicalEmissions: [8.0, 7.2, 6.5, 5.8, 5.4]),
      'GOOGL': ESGData(symbol: 'GOOGL', esgScore: 80.0, carbonEmissions: 8.9, historicalEmissions: [11.0, 10.5, 9.8, 9.2, 8.9]),
      'AMZN': ESGData(symbol: 'AMZN', esgScore: 65.0, carbonEmissions: 45.3, historicalEmissions: [38.0, 42.5, 48.0, 46.5, 45.3]),
      'NKE': ESGData(symbol: 'NKE', esgScore: 70.0, carbonEmissions: 22.1, historicalEmissions: [25.0, 24.2, 23.5, 22.8, 22.1]),
      'SBUX': ESGData(symbol: 'SBUX', esgScore: 78.0, carbonEmissions: 10.5, historicalEmissions: [13.0, 12.5, 11.8, 11.0, 10.5]),
      'OXY': ESGData(symbol: 'OXY', esgScore: 40.0, carbonEmissions: 120.0, historicalEmissions: [130.0, 128.0, 125.0, 122.0, 120.0]), // High emission
      'NEE': ESGData(symbol: 'NEE', esgScore: 85.0, carbonEmissions: 20.0, historicalEmissions: [30.0, 26.5, 24.0, 22.0, 20.0]), // Good energy alternative
      'XOM': ESGData(symbol: 'XOM', esgScore: 30.0, carbonEmissions: 150.0, historicalEmissions: [145.0, 155.0, 160.0, 152.0, 150.0]), // Bad energy example
    };

    if (mockESGDatabase.containsKey(upperSymbol)) {
      return mockESGDatabase[upperSymbol]!;
    }

    // Default return
    return ESGData(symbol: upperSymbol, esgScore: 50.0, carbonEmissions: 40.0, historicalEmissions: [45.0, 43.0, 42.0, 41.0, 40.0]);
  }
}
