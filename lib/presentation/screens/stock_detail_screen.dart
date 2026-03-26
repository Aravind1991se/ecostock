import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/eco_suggestions.dart';
import '../../domain/entities/stock_holding.dart';
import '../providers/portfolio_notifier.dart';

class StockDetailScreen extends ConsumerWidget {
  final StockHolding item;

  const StockDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changeColor = item.dailyChangePercent >= 0 ? const Color(0xFF00E676) : Colors.redAccent;
    final changeIcon = item.dailyChangePercent >= 0 ? Icons.trending_up : Icons.trending_down;
    final ecoTag = item.esgData.ecoTag;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              ref.read(portfolioProvider.notifier).removeStock(item.symbol);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + eco-tag
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEcoTagColor(ecoTag).withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getEcoTagColor(ecoTag).withAlpha(120)),
                  ),
                  child: Text(
                    'Eco $ecoTag',
                    style: TextStyle(color: _getEcoTagColor(ecoTag), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${item.shares.toStringAsFixed(0)} shares @ \$${item.currentPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(width: 12),
                Icon(changeIcon, size: 16, color: changeColor),
                const SizedBox(width: 4),
                Text(
                  '${item.dailyChangePercent >= 0 ? '+' : ''}${item.dailyChangePercent.toStringAsFixed(2)}%',
                  style: TextStyle(color: changeColor, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Financials
            _buildSectionHeader(context, 'Financial Impact', Icons.account_balance_wallet),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Total Position Value',
              value: '\$${item.totalValue.toStringAsFixed(2)}',
              subtitle: 'Based on current market price',
            ),

            const SizedBox(height: 24),

            // Environmental
            _buildSectionHeader(context, 'Environmental Impact', Icons.energy_savings_leaf),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'ESG Score',
                    value: item.esgData.esgScore.toStringAsFixed(1),
                    valueColor: _getEsgColor(item.esgData.esgScore),
                    subtitle: 'Industry Rating',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    title: 'CO₂ Emissions',
                    value: '${item.esgData.carbonEmissions.toStringAsFixed(1)} t',
                    valueColor: Colors.orangeAccent,
                    subtitle: 'Metric Tonnes',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Historical Emissions Chart
            if (item.esgData.historicalEmissions.isNotEmpty) ...[
              _buildSectionHeader(context, 'Historical CO₂ Emissions', Icons.auto_graph),
              const SizedBox(height: 12),
              _buildEmissionsChart(context),
              const SizedBox(height: 24),
            ],

            // Eco-Friendly Suggestion (from sector mapping)
            if (item.isHighEmitter) _buildSuggestionAlert(),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E676).withAlpha(76)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF00E676)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.esgData.esgScore >= 70
                          ? 'This stock positively influences your Green Score. Great job!'
                          : 'Consider diversifying into higher ESG rated companies to improve your overall Green Score.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmissionsChart(BuildContext context) {
    final data = item.esgData.historicalEmissions;
    if (data.isEmpty) return const SizedBox.shrink();

    // Data points (X: 0 to 4 representing last 5 years, Y: emission value)
    final spots = List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index]));
    
    final maxY = data.reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = 0.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Mock years e.g., 2019, 2020, 2021, 2022, 2023
                  final year = 2019 + value.toInt();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(year.toString(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY > 50 ? 50 : 10,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.orangeAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orangeAccent.withAlpha(30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionAlert() {
    final suggestion = EcoSuggestions.getSuggestion(item.symbol);
    if (suggestion == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Eco Alternative Found!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String value, String? subtitle, Color valueColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Color _getEsgColor(double score) {
    if (score >= 70) return const Color(0xFF00E676);
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
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
