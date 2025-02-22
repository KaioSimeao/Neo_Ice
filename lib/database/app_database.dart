import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Importação para gerar o código automaticamente
part 'app_database.g.dart';




// Tabela de Produtos
class Produtos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  RealColumn get valor => real()();
  TextColumn get imagem => text()();
  IntColumn get quantidade =>
      integer().withDefault(const Constant(0))(); // Novo campo
}

// Tabela de Vendedores
@DataClassName('Vendedor')
class Vendedores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 50)();
}

// Tabela de Vendas
class Vendas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vendedorId =>
      integer().customConstraint('REFERENCES vendedores(id) NOT NULL')();
  IntColumn get produtoId =>
      integer().customConstraint('REFERENCES produtos(id) NOT NULL')();
  DateTimeColumn get data => dateTime()();
  RealColumn get valor => real()();
}

// Banco de dados principal
@DriftDatabase(tables: [Produtos, Vendedores, Vendas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Método para listar todos os produtos
  Future<List<Produto>> listarProdutos() {
    return select(produtos).get();
  }

  // Método para inserir um novo produto
  Future<int> inserirProduto(ProdutosCompanion produto) {
    return into(produtos).insert(produto);
  }

  // Método para excluir um produto
  Future<int> excluirProduto(int id) {
    return (delete(produtos)..where((p) => p.id.equals(id))).go();
  }

  // Método para listar vendas
  Future<List<Venda>> listarVendas() => select(vendas).get();

  // Método para inserir uma venda
  Future<int> inserirVenda(VendasCompanion venda) => into(vendas).insert(venda);

  // Método para excluir uma venda
  Future<int> excluirVenda(int id) =>
      (delete(vendas)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> inserirVendedor(VendedoresCompanion vendedor) async {
    await into(vendedores).insert(vendedor);
  }

  Future<List<Vendedor>> listarVendedores() async {
    return await select(vendedores).get();
  }

  Future<void> excluirVendedor(int id) async {
    await (delete(vendedores)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Estratégia de Migração
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from == 1) {
            // Adiciona o campo `quantidade` à tabela Produtos
            await migrator.addColumn(produtos, produtos.quantidade);
          }
        },
      );

  @override
  int get schemaVersion => 2; // Atualize conforme necessário
}

// Função para abrir a conexão com o banco de dados
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app_database.sqlite');
    return NativeDatabase(file);
  });
}
