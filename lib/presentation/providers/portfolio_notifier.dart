import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/remote/alpha_vantage_api.dart';
import '../../data/datasources/remote/esg_api.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/entities/stock_holding.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/usecases/get_portfolio_data_usecase.dart';

// --- Core Providers ---
final dioProvider = Provider<Dio>((ref) => Dio());

final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final alphaVantageApiProvider = Provider<AlphaVantageApi>((ref) {
  return AlphaVantageApi(ref.watch(dioProvider));
});

final esgApiProvider = Provider<ESGApi>((ref) {
  return ESGApi(ref.watch(dioProvider));
});

// --- Repository Providers ---
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepositoryImpl(ref.watch(databaseHelperProvider));
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepositoryImpl(
    alphaVantageApi: ref.watch(alphaVantageApiProvider),
    esgApi: ref.watch(esgApiProvider),
  );
});

// --- UseCase Providers ---
final getPortfolioDataUseCaseProvider = Provider<GetPortfolioDataUseCase>((ref) {
  return GetPortfolioDataUseCase(
    portfolioRepository: ref.watch(portfolioRepositoryProvider),
    stockRepository: ref.watch(stockRepositoryProvider),
  );
});

// --- State Providers ---

class PortfolioNotifier extends AsyncNotifier<List<StockHolding>> {
  @override
  Future<List<StockHolding>> build() async {
    return ref.watch(getPortfolioDataUseCaseProvider).execute();
  }

  Future<void> addStock(String symbol, int quantity) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final stockRepo = ref.read(stockRepositoryProvider);
      final portfolioRepo = ref.read(portfolioRepositoryProvider);
      
      final currentList = state.value ?? [];
      
      final upperSymbol = symbol.toUpperCase();
      final index = currentList.indexWhere((item) => item.symbol == upperSymbol);
      
      StockHolding holdingToSave;
      if (index >= 0) {
        final existingItem = currentList[index];
        holdingToSave = existingItem.copyWith(shares: existingItem.shares + quantity);
      } else {
        // Fetch to get name
        holdingToSave = await stockRepo.getStockData(upperSymbol, quantity);
      }
      
      await portfolioRepo.saveHolding(holdingToSave);
      
      return ref.read(getPortfolioDataUseCaseProvider).execute();
    });
  }

  Future<void> removeStock(String symbol) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(portfolioRepositoryProvider).removeHolding(symbol);
      return ref.read(getPortfolioDataUseCaseProvider).execute();
    });
  }
}

final portfolioProvider = AsyncNotifierProvider<PortfolioNotifier, List<StockHolding>>(() {
  return PortfolioNotifier();
});

// --- Derived State Providers ---
final portfolioTotalsProvider = Provider.autoDispose<Map<String, double>>((ref) {
  final items = ref.watch(portfolioProvider).value ?? [];
  double totalValue = 0.0;
  double totalCO2 = 0.0;
  double totalWeightedScore = 0.0;

  for (var item in items) {
    totalValue += item.totalValue;
    totalCO2 += item.totalCO2Impact;
  }

  if (totalValue > 0) {
    for (var item in items) {
      double weight = item.totalValue / totalValue;
      totalWeightedScore += item.esgData.esgScore * weight;
    }
  }

  return {
    'totalValue': totalValue,
    'totalCO2': totalCO2,
    'greenScore': totalWeightedScore,
  };
});
