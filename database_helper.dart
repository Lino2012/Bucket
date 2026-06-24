import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bucket.dart';
import '../models/document.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bucketvault.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE buckets (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        icon       TEXT    NOT NULL,
        color      TEXT    NOT NULL,
        created_at TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE documents (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        bucket_id       INTEGER NOT NULL,
        name            TEXT    NOT NULL,
        note            TEXT    NOT NULL DEFAULT '',
        file_paths      TEXT    NOT NULL DEFAULT '',
        file_size_bytes INTEGER NOT NULL DEFAULT 0,
        created_at      TEXT    NOT NULL,
        updated_at      TEXT    NOT NULL,
        FOREIGN KEY (bucket_id) REFERENCES buckets (id) ON DELETE CASCADE
      )
    ''');

    // Seed default buckets
    final now = DateTime.now().toIso8601String();
    final defaults = [
      {'name': 'Identity',  'icon': 'identity',  'color': '#EEEDFE', 'created_at': now},
      {'name': 'Travel',    'icon': 'travel',    'color': '#FAEEDA', 'created_at': now},
      {'name': 'Finance',   'icon': 'finance',   'color': '#E6F1FB', 'created_at': now},
      {'name': 'Health',    'icon': 'health',    'color': '#E1F5EE', 'created_at': now},
      {'name': 'Property',  'icon': 'property',  'color': '#FAECE7', 'created_at': now},
    ];
    for (final b in defaults) {
      await db.insert('buckets', b);
    }
  }

  // ── Bucket CRUD ────────────────────────────────────────────────────────────

  Future<int> insertBucket(Bucket bucket) async {
    final db = await database;
    return db.insert('buckets', bucket.toMap());
  }

  Future<List<Bucket>> getAllBuckets() async {
    final db = await database;
    final rows = await db.query('buckets', orderBy: 'created_at ASC');
    return rows.map(Bucket.fromMap).toList();
  }

  Future<Bucket?> getBucketById(int id) async {
    final db = await database;
    final rows = await db.query('buckets', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Bucket.fromMap(rows.first);
  }

  Future<int> updateBucket(Bucket bucket) async {
    final db = await database;
    return db.update(
      'buckets',
      bucket.toMap(),
      where: 'id = ?',
      whereArgs: [bucket.id],
    );
  }

  Future<int> deleteBucket(int id) async {
    final db = await database;
    // documents are cascade-deleted by the FK constraint
    return db.delete('buckets', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns a map of bucketId → document count for all buckets.
  Future<Map<int, int>> getDocumentCountsPerBucket() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT bucket_id, COUNT(*) as cnt FROM documents GROUP BY bucket_id',
    );
    return {
      for (final r in rows) r['bucket_id'] as int: r['cnt'] as int,
    };
  }

  // ── Document CRUD ──────────────────────────────────────────────────────────

  Future<int> insertDocument(Document document) async {
    final db = await database;
    return db.insert('documents', document.toMap());
  }

  Future<List<Document>> getDocumentsForBucket(int bucketId) async {
    final db = await database;
    final rows = await db.query(
      'documents',
      where: 'bucket_id = ?',
      whereArgs: [bucketId],
      orderBy: 'created_at DESC',
    );
    return rows.map(Document.fromMap).toList();
  }

  Future<Document?> getDocumentById(int id) async {
    final db = await database;
    final rows = await db.query('documents', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Document.fromMap(rows.first);
  }

  Future<int> updateDocument(Document document) async {
    final db = await database;
    return db.update(
      'documents',
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  /// Search documents by name across all buckets.
  Future<List<Document>> searchDocuments(String query) async {
    final db = await database;
    final rows = await db.query(
      'documents',
      where: 'name LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return rows.map(Document.fromMap).toList();
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) await db.close();
    _db = null;
  }
}
