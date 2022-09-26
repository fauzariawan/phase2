import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workplan_beta_test/model/user/user.dart';

class UsersDatabase {
  UsersDatabase.internal();
  static final UsersDatabase _instance = UsersDatabase.internal();
  factory UsersDatabase() => _instance;
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb("users.db");
    return _db!;
  }

  initDb(String fileName) async {
    // io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, fileName);
    var theDb = await openDatabase(path, version: 1, onCreate: _createDB);
    return theDb;
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute(
        '''CREATE TABLE User (id_pk INTEGER PRIMARY KEY AUTOINCREMENT,id INTEGER ,email TEXT,encrypted_password TEXT, username TEXT, full_name TEXT, phone TEXT, language_type INTEGER,company_code TEXT,is_biometrik TEXT,organization_id INTEGER,function_id INTEGER,structure_id INTEGER,employee_status INTEGER,user_company_id INTEGER,package_type INTEGER,role_id INTEGER,is_login_mobile TEXT,timeout_login INTEGER,last_sign_in_at TEXT,resign_date TEXT, resign_flag INTEGER,device_id TEXT, validation_face_type INTEGER, is_face_recognition_registered INTEGER, is_face_recognition_validated INTEGER)''');

    // await db.execute('''
    // CREATE TABLE $tableNotes(
    //   ${NoteFields.id} $idType,
    //   ${NoteFields.isImportant} $boolType,
    //   ${NoteFields.number} $integerType,
    //   ${NoteFields.title} $textType,
    //   ${NoteFields.description} $textType,
    //   ${NoteFields.createdTime} $textType
    // )
    // ''');
  }

  Future<User> createUser(User user) async {
    final database = await db;
    return await database.transaction((txn) async {
      final id = await txn.insert(tableUsers, user.toJson());
      print(user.copy(id: user.id).toJson());
      return user.copy(id: user.id);
    });
  }

  Future<int> deleteAllUser() async {
    final database = await db;
    // hapus seluruh user
    return await database.transaction((txn) async {
      var result = await database.delete(tableUsers);
      // // hapus satu user yang di inginkan
      // var result = await database
      //     .delete(tableUsers, where: '${NoteFields.id} = ?', whereArgs: [id]);
      print('result dari delete note');
      print(result);
      return result;
    });
  }

  Future<List<User>?> getAllUsers() async {
    final database = await db;
    // const orderBy = '${NoteFields.createdTime} ASC';
    // return await database.transaction((txn) async {
    //   var result =  await database.query(tableNotes, orderBy: orderBy);
    //   return result.map((json) => Note.fromJson(json)).toList();
    // });
    final result = await database.query(tableUsers);
    return result.map((json) => User.fromJson(json)).toList();

    // // manually
    // // final result =
    // //     await database.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    // return result.map((json) => Note.fromJson(json)).toList();
  }
}
