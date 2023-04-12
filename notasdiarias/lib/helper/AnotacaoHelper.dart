import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/anotacao.dart';

class AnotacaoHelper{
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  static final tabelaAnotacao = 'anotacao';
  Database? _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal(){

  }

  get db async {
    if(_db != null){
      return _db;
    } else {
      _db = await _inicializarDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql = 'CREATE TABLE anotacao(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)';
    await db.execute(sql);
  }

  _inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, 'bancoMinhasAnotacoes.db');
    var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
  var bancoDados = await db;
  int result = await bancoDados.insert(tabelaAnotacao, anotacao.toMap());
  return result;
  }

  listarAnotacoes() async {
    var bancoDados = await db;
    String sql = 'SELECT * FROM $tabelaAnotacao ORDER BY data DESC';
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;
    return await bancoDados.update(
      tabelaAnotacao,
      anotacao.toMap(),
      where: 'id = ?',
      whereArgs: [anotacao.id]
    );
  }

  Future<int> removerAnotacao(int id) async {
    var bancoDados = await db;
    return await bancoDados.delete(
        tabelaAnotacao,
        where: 'id = ?',
        whereArgs: [id]
    );
  }
}

/*
class Singleton {
  static final Singleton _singleton = Singleton._internal();

  factory Singleton(){
    return _singleton;
  }

  Singleton._internal(){
  }
}
*/
