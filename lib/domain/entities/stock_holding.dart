import 'esg_data.dart';

class StockHolding {
  final String symbol;
  final String name;
  final double shares;
  final double currentPrice;
  final double dailyChangePercent;
  final ESGData esgData;

  const StockHolding({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.currentPrice,
    this.dailyChangePercent = 0.0,
    required this.esgData,
  });

  double get totalValue => shares * currentPrice;
  double get totalCO2Impact => shares * esgData.carbonEmissions;
  bool get isHighEmitter => esgData.carbonEmissions > 50;

  StockHolding copyWith({
    String? symbol,
    String? name,
    double? shares,
    double? currentPrice,
    double? dailyChangePercent,
    ESGData? esgData,
  }) {
    return StockHolding(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      shares: shares ?? this.shares,
      currentPrice: currentPrice ?? this.currentPrice,
      dailyChangePercent: dailyChangePercent ?? this.dailyChangePercent,
      esgData: esgData ?? this.esgData,
    );
  }
}
