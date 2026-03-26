/// Sector mapping and eco-friendly alternative suggestions.
///
/// When a user holds a high-emission stock, we look up its sector and suggest
/// the highest-ESG-rated stock in that sector as a greener alternative.
library;

class EcoSuggestions {
  // Map each stock symbol to a sector
  static const Map<String, String> _sectorMap = {
    'AAPL': 'Technology',
    'MSFT': 'Technology',
    'GOOGL': 'Technology',
    'AMZN': 'Consumer Discretionary',
    'TSLA': 'Consumer Discretionary',
    'NKE': 'Consumer Staples',
    'SBUX': 'Consumer Staples',
    'OXY': 'Energy',
    'XOM': 'Energy',
    'NEE': 'Energy',
  };

  // Best ESG alternative per sector (symbol → name, carbon reduction %)
  static const Map<String, _Alternative> _bestAlternatives = {
    'Energy': _Alternative(
      symbol: 'NEE',
      name: 'NextEra Energy',
      carbonReduction: 40,
    ),
    'Technology': _Alternative(
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      carbonReduction: 25,
    ),
    'Consumer Discretionary': _Alternative(
      symbol: 'TSLA',
      name: 'Tesla Inc.',
      carbonReduction: 35,
    ),
    'Consumer Staples': _Alternative(
      symbol: 'SBUX',
      name: 'Starbucks Corp.',
      carbonReduction: 20,
    ),
  };

  /// Returns a suggestion string for a high-emitter stock, or null if
  /// the stock is already the best alternative or no mapping exists.
  static String? getSuggestion(String symbol) {
    final upperSymbol = symbol.toUpperCase();
    final sector = _sectorMap[upperSymbol];
    if (sector == null) return null;

    final alt = _bestAlternatives[sector];
    if (alt == null) return null;

    // Don't suggest the stock itself
    if (alt.symbol == upperSymbol) return null;

    return 'Consider ${alt.name} (${alt.symbol})—it has a '
        '${alt.carbonReduction}% lower carbon footprint than $upperSymbol.';
  }

  /// Returns the sector name for a given stock symbol.
  static String? getSector(String symbol) => _sectorMap[symbol.toUpperCase()];
}

class _Alternative {
  final String symbol;
  final String name;
  final int carbonReduction;

  const _Alternative({
    required this.symbol,
    required this.name,
    required this.carbonReduction,
  });
}
