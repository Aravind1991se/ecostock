class ESGData {
  final String symbol;
  final double esgScore; // 0 to 100
  final double carbonEmissions; // in metric tons
  final List<double> historicalEmissions; // Last 5 years (oldest to newest)

  const ESGData({
    required this.symbol,
    required this.esgScore,
    required this.carbonEmissions,
    this.historicalEmissions = const [],
  });

  /// Maps ESG score to a letter grade: A (≥75), B (≥50), C (≥25), D (<25).
  String get ecoTag {
    if (esgScore >= 75) return 'A';
    if (esgScore >= 50) return 'B';
    if (esgScore >= 25) return 'C';
    return 'D';
  }
}
