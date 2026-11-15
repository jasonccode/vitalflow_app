import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vitalflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        duration INTEGER NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // Perfil del usuario: una sola fila con la ruta de la foto de perfil
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        photo_path TEXT
      )
    ''');
  }

  // CREATE: Insertar rutina
  Future<int> insertRoutine(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('routines', row);
  }

  // READ: Consultar todas las rutinas
  Future<List<Map<String, dynamic>>> getRoutines() async {
    final db = await instance.database;
    return await db.query('routines', orderBy: 'id DESC');
  }

  // UPDATE: Actualizar rutina
  Future<int> updateRoutine(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      'routines',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Eliminar rutina
  Future<int> deleteRoutine(int id) async {
    final db = await instance.database;
    return await db.delete(
      'routines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // FOTO DE PERFIL: Consultar la ruta guardada (null si no hay foto)
  Future<String?> getProfilePhoto() async {
    final db = await instance.database;
    final rows = await db.query('profile', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;
    return rows.first['photo_path'] as String?;
  }

  // FOTO DE PERFIL: Guardar la ruta (reemplaza la anterior)
  Future<void> saveProfilePhoto(String photoPath) async {
    final db = await instance.database;
    await db.insert(
      'profile',
      {'id': 1, 'photo_path': photoPath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}