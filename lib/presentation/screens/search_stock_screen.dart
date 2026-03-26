import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stock_holding.dart';
import '../providers/portfolio_notifier.dart';

class SearchStockScreen extends ConsumerStatefulWidget {
  const SearchStockScreen({super.key});

  @override
  ConsumerState<SearchStockScreen> createState() => _SearchStockScreenState();
}

class _SearchStockScreenState extends ConsumerState<SearchStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<StockHolding> _searchResults = [];
  bool _isSearching = false;

  void _performSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
      return;
    }
    setState(() => _isSearching = true);

    final stockRepo = ref.read(stockRepositoryProvider);
    final results = await stockRepo.searchStocks(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _addStock(StockHolding stock) {
    showDialog(
      context: context,
      builder: (ctx) {
        int quantity = 1;
        return AlertDialog(
          backgroundColor: const Color(0xFF151C2C),
          title: Text('Add ${stock.symbol}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How many shares of ${stock.name} do you own?'),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '1',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  quantity = int.tryParse(val) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(portfolioProvider.notifier)
                    .addStock(stock.symbol, quantity);
                Navigator.pop(ctx);
                if (mounted) {
                  Navigator.pop(context); // Go back to dashboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Adding $quantity shares of ${stock.symbol}',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
              ),
              child: const Text('Add to Portfolio'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Stocks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by symbol or name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF151C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF00E676)),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: Color(0xFF00E676)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final stock = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withAlpha(12),
                      child: Text(
                        stock.symbol[0],
                        style: const TextStyle(color: Color(0xFF00E676)),
                      ),
                    ),
                    title: Text(
                      stock.symbol,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(stock.name),
                    trailing: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF00E676),
                    ),
                    onTap: () => _addStock(stock),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
