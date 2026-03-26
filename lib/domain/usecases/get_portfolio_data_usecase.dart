import '../entities/stock_holding.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/stock_repository.dart';

class GetPortfolioDataUseCase {
  final PortfolioRepository portfolioRepository;
  final StockRepository stockRepository;

  GetPortfolioDataUseCase({
    required this.portfolioRepository,
    required this.stockRepository,
  });

  Future<List<StockHolding>> execute() async {
    // 1. Get local persistent portfolio (just symbols and quantities)
    final localHoldings = await portfolioRepository.getLocalPortfolio();
    
    // 2. Fetch live data for each holding (price, esg score)
    List<StockHolding> updatedHoldings = [];
    for (var holding in localHoldings) {
      try {
        final liveData = await stockRepository.getStockData(holding.symbol, holding.shares.toInt());
        updatedHoldings.add(liveData);
        // Ensure local values match latest name if necessary, though we don't strict update the db on read yet.
      } catch (e) {
        // Fallback to local if remote fails
        updatedHoldings.add(holding);
      }
    }
    
    return updatedHoldings;
  }
}
