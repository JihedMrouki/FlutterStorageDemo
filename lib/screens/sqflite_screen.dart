import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteScreen extends StatefulWidget {
  const SQLiteScreen({super.key});

  @override
  State<SQLiteScreen> createState() => _SQLiteScreenState();
}

class _SQLiteScreenState extends State<SQLiteScreen> {
  late Database _database;
  final List<Map<String, dynamic>> _products = [];
  final List<String> _transactionLog = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            category TEXT
          )
        ''');
        debugPrint('Table created');
      },
    );
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _database.query('products');
    setState(() => _products.clear());
    setState(() => _products.addAll(products));
    debugPrint('Loaded ${products.length} products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Advanced Features'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Basic CRUD Operations
            _buildCrudSection(),
            const SizedBox(height: 20),

            // 2. SQL Helper Examples
            _buildSqlHelpersSection(),
            const SizedBox(height: 20),

            // 3. Map Example
            _buildMapExampleSection(),
            const SizedBox(height: 20),

            // 4. Transactions
            _buildTransactionSection(),
            const SizedBox(height: 20),

            // 5. Batch Operations
            _buildBatchSection(),
            const SizedBox(height: 20),

            // Debug Controls
            _buildDebugControls(),
          ],
        ),
      ),
    );
  }

  // ========== 1. Basic CRUD Operations ==========
  Widget _buildCrudSection() {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🛒 Basic CRUD Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addSampleProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Sample Product'),
            ),
            const SizedBox(height: 10),
            if (_products.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      title: Text(product['name']),
                      subtitle: Text(
                        '\$${product['price']} - ${product['category']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product['id']),
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No products yet', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _addSampleProduct() async {
    const sampleProducts = [
      {'name': 'Laptop', 'price': 999.99, 'category': 'Electronics'},
      {'name': 'Smartphone', 'price': 699.99, 'category': 'Electronics'},
      {'name': 'Headphones', 'price': 149.99, 'category': 'Accessories'},
    ];

    final randomProduct =
        sampleProducts[DateTime.now().millisecond % sampleProducts.length];
    final id = await _database.insert('products', randomProduct);
    debugPrint('Inserted product with id $id: $randomProduct');
    _loadProducts();
  }

  Future<void> _deleteProduct(int id) async {
    await _database.delete('products', where: 'id = ?', whereArgs: [id]);
    debugPrint('Deleted product $id');
    _loadProducts();
  }

  // ========== 2. SQL Helper Examples ==========
  Widget _buildSqlHelpersSection() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '📊 SQL Helpers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _runQuery('SELECT * FROM products'),
                  child: const Text('SELECT *'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _runQuery('SELECT name, price FROM products'),
                  child: const Text('SELECT cols'),
                ),
                ElevatedButton(
                  onPressed:
                      () =>
                          _runQuery('SELECT * FROM products WHERE price > 500'),
                  child: const Text('WHERE clause'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _runQuery(
                        'SELECT * FROM products ORDER BY price DESC',
                      ),
                  child: const Text('ORDER BY'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Results will appear in debug console',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runQuery(String sql) async {
    debugPrint('\nExecuting: $sql');
    final result = await _database.rawQuery(sql);
    debugPrint('Results:');
    for (final row in result) {
      debugPrint(row.toString());
    }
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(content: Text('Executed: ${sql.split(' ').first}...')),
    );
  }

  // ========== 3. Map Example ==========
  Widget _buildMapExampleSection() {
    return Card(
      elevation: 4,
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🗺️ Map Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Demonstrating map() on query results:'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showMappedResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Map Product Names'),
            ),
            const SizedBox(height: 10),
            if (_products.isNotEmpty)
              Text(
                'Mapped names: ${_products.map((p) => p['name']).join(', ')}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMappedResults() async {
    final products = await _database.query('products');
    final names = products.map((p) => p['name']).toList();
    final prices = products.map((p) => p['price'] as double).toList();

    debugPrint('\nMap Example:');
    debugPrint('Names: $names');
    debugPrint('Prices: $prices');

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(content: Text('Mapped results printed to console')),
    );
  }

  // ========== 4. Transactions ==========
  Widget _buildTransactionSection() {
    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '💾 Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('All operations complete or none do'),
            const SizedBox(height: 10),
            Column(children: _transactionLog.map((log) => Text(log)).toList()),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runSuccessfulTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Run Success'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _runFailingTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Run Failure'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runSuccessfulTransaction() async {
    setState(() => _transactionLog.clear());

    await _database.transaction((txn) async {
      setState(() => _transactionLog.add('1. Inserting product A...'));
      await txn.insert('products', {
        'name': 'Product A',
        'price': 19.99,
        'category': 'Transaction',
      });

      setState(() => _transactionLog.add('2. Inserting product B...'));
      await txn.insert('products', {
        'name': 'Product B',
        'price': 29.99,
        'category': 'Transaction',
      });

      setState(() => _transactionLog.add('3. Updating prices...'));
      await txn.update(
        'products',
        {'price': 9.99},
        where: 'category = ?',
        whereArgs: ['Transaction'],
      );
    });

    setState(() => _transactionLog.add('✅ Transaction completed!'));
    _loadProducts();
  }

  Future<void> _runFailingTransaction() async {
    setState(() => _transactionLog.clear());

    try {
      await _database.transaction((txn) async {
        setState(() => _transactionLog.add('1. Inserting product X...'));
        await txn.insert('products', {
          'name': 'Product X',
          'price': 39.99,
          'category': 'Failed',
        });

        setState(() => _transactionLog.add('2. Inserting product Y...'));
        await txn.insert('products', {
          'name': 'Product Y',
          'price': 49.99,
          'category': 'Failed',
        });

        // Intentional error
        throw Exception('💥 Simulated error!');
      });
    } catch (e) {
      setState(() => _transactionLog.add('❌ Error: $e'));
      setState(() => _transactionLog.add('🔙 Transaction rolled back'));
    }

    // Verify rollback
    final failedProducts = await _database.query(
      'products',
      where: 'category = ?',
      whereArgs: ['Failed'],
    );

    setState(
      () => _transactionLog.add(
        'Verification: ${failedProducts.isEmpty ? 'No products persisted' : 'Error: Products found!'}',
      ),
    );
    _loadProducts();
  }

  // ========== 5. Batch Operations ==========
  Widget _buildBatchSection() {
    return Card(
      elevation: 4,
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '📦 Batch Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _runBatchOperations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Execute Batch'),
              ),
            const SizedBox(height: 10),
            const Text('Batch executes multiple operations at once'),
          ],
        ),
      ),
    );
  }

  Future<void> _runBatchOperations() async {
    setState(() => _isProcessing = true);

    final batch = _database.batch();
    debugPrint('\nStarting batch operation...');

    // Add operations to batch
    batch.insert('products', {
      'name': 'Batch Item 1',
      'price': 10.0,
      'category': 'Batch',
    });
    debugPrint('Added insert 1 to batch');

    batch.insert('products', {
      'name': 'Batch Item 2',
      'price': 20.0,
      'category': 'Batch',
    });
    debugPrint('Added insert 2 to batch');

    batch.update(
      'products',
      {'price': 5.0},
      where: 'category = ?',
      whereArgs: ['Batch'],
    );
    debugPrint('Added update to batch');

    // Execute batch
    await batch.commit(noResult: true);
    debugPrint('Batch committed successfully');

    setState(() => _isProcessing = false);
    _loadProducts();
    ScaffoldMessenger.of(
      this.context,
    ).showSnackBar(const SnackBar(content: Text('Batch operation completed')));
  }

  // ========== Debug Controls ==========
  Widget _buildDebugControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🐞 Debug Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _printDatabasePath,
              child: const Text('Print DB Path'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearDatabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All Data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printDatabasePath() async {
    final dbPath = await getDatabasesPath();
    debugPrint('Database path: $dbPath/products.db');
    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(content: Text('Database path printed to console')),
    );
  }

  Future<void> _clearDatabase() async {
    await _database.delete('products');
    setState(() => _products.clear());
    debugPrint('Database cleared');
    ScaffoldMessenger.of(
      this.context,
    ).showSnackBar(const SnackBar(content: Text('All data cleared')));
  }
}
