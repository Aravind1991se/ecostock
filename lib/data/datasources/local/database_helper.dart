import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/stock_holding.dart';
import '../../../domain/entities/esg_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('portfolio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final path = join(docsPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE portfolio (
  symbol TEXT PRIMARY KEY,
  name TEXT,
  shares REAL
)
''');
  }

  Future<void> insertOrUpdateHolding(StockHolding holding) async {
    final db = await instance.database;
    await db.insert(
      'portfolio',
      {
        'symbol': holding.symbol,
        'name': holding.name,
        'shares': holding.shares,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeHolding(String symbol) async {
    final db = await instance.database;
    await db.delete(
      'portfolio',
      where: 'symbol = ?',
      whereArgs: [symbol.toUpperCase()],
    );
  }

  Future<List<StockHolding>> getAllHoldings() async {
    final db = await instance.database;
    final result = await db.query('portfolio');

    return result.map((json) {
      return StockHolding(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        shares: (json['shares'] as num).toDouble(),
        // Defaults, to be updated by remote data
        currentPrice: 0.0,
        esgData: ESGData(symbol: json['symbol'] as String, esgScore: 0.0, carbonEmissions: 0.0, historicalEmissions: []),
      );
    }).toList();
  }
}
