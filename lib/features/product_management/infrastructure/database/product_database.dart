import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'product_table.dart';
import 'product_dao.dart';

part 'product_database.g.dart';

/// Main database class for Product Management
/// Uses Drift (SQLite) for local persistence
@DriftDatabase(
  tables: [ProductTable],
  daos: [ProductDao],
)
class ProductDatabase extends _$ProductDatabase {
  /// Constructor for the database
  ProductDatabase() : super(_openConnection());

  /// Constructor for testing with custom executor
  ProductDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will go here
        // Example:
        // if (from == 1 && to == 2) {
        //   await m.addColumn(productTable, productTable.newColumn);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys if needed
        // await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Close the database connection
  Future<void> close() async {
    await super.close();
  }

  /// Clear all products (for testing/development)
  Future<void> clearAllProducts() async {
    await delete(productTable).go();
  }
}

/// Opens the database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'products.db'));

    return NativeDatabase.createInBackground(
      file,
      logStatements: true, // Set to false in production
    );
  });
}
