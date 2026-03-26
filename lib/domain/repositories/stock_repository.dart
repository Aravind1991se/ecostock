import '../entities/stock_holding.dart';

abstract class StockRepository {
  Future<StockHolding> getStockData(String symbol, int quantity);
  Future<List<StockHolding>> searchStocks(String query);
}
