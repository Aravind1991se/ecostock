import '../../domain/entities/esg_data.dart';
import '../../domain/entities/stock_holding.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/remote/alpha_vantage_api.dart';
import '../datasources/remote/esg_api.dart';

class StockRepositoryImpl implements StockRepository {
  final AlphaVantageApi alphaVantageApi;
  final ESGApi esgApi;

  StockRepositoryImpl({
    required this.alphaVantageApi,
    required this.esgApi,
  });

  @override
  Future<StockHolding> getStockData(String symbol, int quantity) async {
    final results = await Future.wait([
      alphaVantageApi.getCurrentPrice(symbol),
      alphaVantageApi.getDailyChangePercent(symbol),
    ]);
    final currentPrice = results[0];
    final dailyChange = results[1];
    final esgData = await esgApi.getESGData(symbol);

    return StockHolding(
      symbol: symbol.toUpperCase(),
      name: symbol.toUpperCase(),
      shares: quantity.toDouble(),
      currentPrice: currentPrice,
      dailyChangePercent: dailyChange,
      esgData: esgData,
    );
  }

  @override
  Future<List<StockHolding>> searchStocks(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lowerQuery = query.toLowerCase();

    final mockDatabase = [
      StockHolding(symbol: 'AAPL', name: 'Apple Inc.', shares: 0, currentPrice: 175.50, esgData: const ESGData(symbol: 'AAPL', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'TSLA', name: 'Tesla Inc.', shares: 0, currentPrice: 202.10, esgData: const ESGData(symbol: 'TSLA', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'MSFT', name: 'Microsoft Corp.', shares: 0, currentPrice: 420.30, esgData: const ESGData(symbol: 'MSFT', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'GOOGL', name: 'Alphabet Inc.', shares: 0, currentPrice: 168.40, esgData: const ESGData(symbol: 'GOOGL', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'AMZN', name: 'Amazon.com Inc.', shares: 0, currentPrice: 185.20, esgData: const ESGData(symbol: 'AMZN', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'NKE', name: 'NIKE Inc.', shares: 0, currentPrice: 95.60, esgData: const ESGData(symbol: 'NKE', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'SBUX', name: 'Starbucks Corp.', shares: 0, currentPrice: 85.30, esgData: const ESGData(symbol: 'SBUX', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'OXY', name: 'Occidental Petroleum', shares: 0, currentPrice: 65.40, esgData: const ESGData(symbol: 'OXY', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'NEE', name: 'NextEra Energy', shares: 0, currentPrice: 70.20, esgData: const ESGData(symbol: 'NEE', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
      StockHolding(symbol: 'XOM', name: 'Exxon Mobil', shares: 0, currentPrice: 110.50, esgData: const ESGData(symbol: 'XOM', esgScore: 0, carbonEmissions: 0, historicalEmissions: [])),
    ];

    return mockDatabase.where((stock) {
      return stock.symbol.toLowerCase().contains(lowerQuery) ||
             stock.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
