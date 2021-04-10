import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String DATE_FORMAT = 'yyyy-MM-dd';

class DatabaseHelper {
  static final _databaseName = "knowyournumber.db";
  static final _databaseVersion = 1;

  static final categoryTable = 'category';
  static final accountTable = 'account';
  static final transactionTable = 'mtransaction';

  static final columnId = 'id';
  static final columnIdCreateStatement = 'id INTEGER PRIMARY KEY';
  static final columnTransactionId = 'transactionId';
  static final columnName = 'name';
  static final columnDescription = 'description';
  static final columnBudget = 'budget';
  static final columnOwner = 'owner';
  static final columnType = 'type';
  static final columnAmount = 'amount';
  static final columnBalance = 'balance';
  static final columnCurrency = 'currency';
  static final columnInterestRate = 'interest_rate';
  static final columnIcon = 'icon';
  static final columnDate = 'date';
  static final columnNote = 'note';
  static final columnCategoryId = 'category_id';
  static final columnMerchant = 'merchant';
  static final columnFrequency = 'frequency';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $categoryTable (
            $columnIdCreateStatement,
            $columnName TEXT NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnBudget DOUBLE DEFAULT 0,
            $columnFrequency INT DEFAULT 2
          )
          ''');
    await db.execute('''
          CREATE TABLE $accountTable (
            $columnIdCreateStatement,
            $columnType TEXT NOT NULL,
            $columnOwner TEXT NOT NULL,
            $columnInterestRate DOUBLE DEFAULT 0,
            $columnBalance DOUBLE DEFAULT 0,
            $columnCurrency TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $transactionTable (
            $columnIdCreateStatement,
            $columnDate INT NULL,
            $columnDescription TEXT NOT NULL,
            $columnType INTEGER NOT NULL,
            $columnAmount DOUBLE DEFAULT 0,
            $columnCategoryId INTEGER NOT NULL,
            $columnMerchant TEXT NULL,
            FOREIGN KEY($columnCategoryId) REFERENCES $categoryTable($columnId)
          )
          ''');
    await db.insert(categoryTable, {
      columnName: "Meal",
      columnDescription: "Dine out or takeaway meal",
      columnBudget: 1000000,
      columnFrequency: 2,
    });
    await db.insert(categoryTable, {
      columnName: "Housing",
      columnDescription: "Purchases for the House",
      columnBudget: 1000000,
      columnFrequency: 2,
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(tableName, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
      String tableName, String whereClaues) async {
    Database db = await instance.database;
    return await db.query(tableName, where: whereClaues);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount(String tableName) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(tableName, Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db
        .update(tableName, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(tableName, int id) async {
    Database db = await instance.database;
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> execute(String query) async {
    Database db = await instance.database;
    return await db.execute(query);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String query) async {
    Database db = await instance.database;
    return await db.rawQuery(query);
  }
}
