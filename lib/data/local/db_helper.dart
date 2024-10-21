import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  //Single Tone
  DBHelper._();

  static final DBHelper getInstance = DBHelper._();

  // create note
  static const String TABLE_NOTE = "note";
  static const String COLUMN_NOTE_SNO = "s_no";
  static const String COLUMN_NOTE_TITLE = "title";
  static const String COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  //DB Open (path -> if exist then open else create Database
  Future<Database> getDB() async {
    // myDB ?? await openDB();
    // return myDB!;

    if (myDB != null) {
      return myDB!;
    } else {
      myDB = await openDB();
      return myDB!;
    }
  }

  Future<Database> openDB() async {
    Directory appPath = await getApplicationDocumentsDirectory();

    String dbPath = join(appPath.path, "noteDB.db");

    return await openDatabase(dbPath, onCreate: (db, version) {
      //create tables here
      db.execute(
          "create table $TABLE_NOTE($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)");

      //we can create multiple tables in the database
    }, version: 1);
  }

  //all queries

  //Insertion Data
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();

    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    });

    return rowsEffected > 0;
  }

  //Reading All Data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);

    return mData;
  }

  //Update Data
  Future<bool> updateNote(
      {required String mTitle, required String mDesc, required int sno}) async {
    var db = await getDB();

    int rowsEffected = await db.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TITLE: mTitle,
          COLUMN_NOTE_DESC: mDesc,
        },
        where: "$COLUMN_NOTE_SNO = $sno");

    return rowsEffected > 0;
  }

  //delete Data
  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();

    int rowsEffected = await db
        .delete(TABLE_NOTE, where: "$COLUMN_NOTE_SNO = ?", whereArgs: ['$sno']);

    return rowsEffected > 0;
  }
}
