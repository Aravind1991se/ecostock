import '../entities/stock_holding.dart';

abstract class PortfolioRepository {
  Future<List<StockHolding>> getLocalPortfolio();
  Future<void> saveHolding(StockHolding holding);
  Future<void> removeHolding(String symbol);
}
