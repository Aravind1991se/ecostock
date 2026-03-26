import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stock_holding.dart';
import '../providers/portfolio_notifier.dart';
import 'search_stock_screen.dart';
import 'stock_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsyncValue = ref.watch(portfolioProvider);
    final totals = ref.watch(portfolioTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Portfolio', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E676)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchStockScreen()),
              );
            },
          )
        ],
      ),
      body: portfolioAsyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(portfolioProvider);
              await ref.read(portfolioProvider.future);
            },
            color: const Color(0xFF00E676),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildHeaderCard(totals),
                const SizedBox(height: 16),
                _buildGaugeRow(totals),
                const SizedBox(height: 24),
                Text('Your Holdings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...items.map((item) => _buildStockCard(context, item)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_rounded, size: 80, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text(
            'Your portfolio is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some stocks to see your Green Score',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchStockScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          )
        ],
      ),
    );
  }

  // ─── Header Card: Total Value + CO2 footprint ───
  Widget _buildHeaderCard(Map<String, double> totals) {
    final totalValue = totals['totalValue']!;
    final totalCO2 = totals['totalCO2']!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151C2C), Color(0xFF1A233A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Portfolio Value', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orangeAccent.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.factory_rounded, size: 14, color: Colors.orangeAccent),
                const SizedBox(width: 6),
                Text(
                  'Your portfolio emits ${totalCO2.toStringAsFixed(1)} tons of CO₂/year',
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Gauge Row: Green Score Ring + CO2 Metric ───
  Widget _buildGaugeRow(Map<String, double> totals) {
    final greenScore = totals['greenScore']!;
    final totalCO2 = totals['totalCO2']!;

    return Row(
      children: [
        // Green Score Gauge
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151C2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Column(
              children: [
                const Text('Green Score', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _GreenScoreGaugePainter(score: greenScore),
                    child: Center(
                      child: Text(
                        greenScore.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(greenScore),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreLabel(greenScore),
                  style: TextStyle(color: _getScoreColor(greenScore), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // CO2 Impact Metric
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151C2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.factory, color: Colors.orangeAccent, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CO₂ Impact',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${totalCO2.toStringAsFixed(1)} t',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text('metric tonnes/yr', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Stock Card with Eco-Tag and Daily Change ───
  Widget _buildStockCard(BuildContext context, StockHolding item) {
    final changeColor = item.dailyChangePercent >= 0 ? const Color(0xFF00E676) : Colors.redAccent;
    final changeIcon = item.dailyChangePercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    final ecoTag = item.esgData.ecoTag;
    final ecoTagColor = _getEcoTagColor(ecoTag);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StockDetailScreen(item: item)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Symbol avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.symbol.substring(0, 1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF00E676)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name / shares
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        // Eco-Tag badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: ecoTagColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ecoTagColor.withAlpha(120), width: 1),
                          ),
                          child: Text(
                            ecoTag,
                            style: TextStyle(color: ecoTagColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${item.shares.toStringAsFixed(0)} shares', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              // Value + daily change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${item.totalValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(changeIcon, size: 12, color: changeColor),
                      const SizedBox(width: 2),
                      Text(
                        '${item.dailyChangePercent.abs().toStringAsFixed(2)}%',
                        style: TextStyle(color: changeColor, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───
  Color _getScoreColor(double score) {
    if (score >= 75) return const Color(0xFF00E676);
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getScoreLabel(double score) {
    if (score >= 75) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 25) return 'Fair';
    return 'Poor';
  }

  Color _getEcoTagColor(String tag) {
    switch (tag) {
      case 'A': return const Color(0xFF00E676);
      case 'B': return Colors.lightBlueAccent;
      case 'C': return Colors.orangeAccent;
      case 'D': return Colors.redAccent;
      default:  return Colors.grey;
    }
  }
}

// ─── Custom Painter: Sustainability Gauge Ring ───
class _GreenScoreGaugePainter extends CustomPainter {
  final double score;

  _GreenScoreGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const startAngle = -pi * 0.75; // start at 7 o'clock
    const sweepTotal = pi * 1.5;   // 270-degree arc
    final sweepAngle = sweepTotal * (score / 100).clamp(0.0, 1.0);

    // Background track
    final bgPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      bgPaint,
    );

    // Score arc with gradient
    Color arcColor;
    if (score >= 75) {
      arcColor = const Color(0xFF00E676);
    } else if (score >= 50) {
      arcColor = Colors.orangeAccent;
    } else {
      arcColor = Colors.redAccent;
    }

    final scorePaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GreenScoreGaugePainter oldDelegate) => oldDelegate.score != score;
}
