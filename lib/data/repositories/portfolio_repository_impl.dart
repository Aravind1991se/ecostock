import '../../../domain/entities/stock_holding.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../datasources/local/database_helper.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final DatabaseHelper databaseHelper;

  PortfolioRepositoryImpl(this.databaseHelper);

  @override
  Future<List<StockHolding>> getLocalPortfolio() async {
    return await databaseHelper.getAllHoldings();
  }

  @override
  Future<void> saveHolding(StockHolding holding) async {
    await databaseHelper.insertOrUpdateHolding(holding);
  }

  @override
  Future<void> removeHolding(String symbol) async {
    await databaseHelper.removeHolding(symbol);
  }
}
