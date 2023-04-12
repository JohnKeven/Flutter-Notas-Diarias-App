import 'package:flutter/material.dart';
import 'helper/AnotacaoHelper.dart';
import 'model/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  List<Anotacao> _anotacoes = [];

  var db = AnotacaoHelper();

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    int result;
    if(anotacaoSelecionada == null){
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      result = await db.salvarAnotacao(anotacao);
    } else {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      result = await db.atualizarAnotacao(anotacaoSelecionada);
    }
    _tituloController.clear();
    _descricaoController.clear();
    _listarAnotacoes();
    return result;
  }

  _listarAnotacoes() async {
    List anotacoesList = await db.listarAnotacoes();

    List<Anotacao> anotacoesTemp = [];
    for(var item in anotacoesList){
      Anotacao anotacao = Anotacao.fromMap(item);
      anotacoesTemp.add(anotacao);
    }

    setState(() {
      _anotacoes = anotacoesTemp;
    });
    anotacoesTemp = [];

  }

  _removerAnotacao(int id) async {
    await db.removerAnotacao(id);
    _listarAnotacoes();
  }

  _exibirTelaCadastro({Anotacao? anotacao}){
    String textoSalvarAtualizar = '';
    if(anotacao == null){
      _tituloController.text = '';
      _descricaoController.text = '';
      textoSalvarAtualizar = 'Salvar';
    } else {
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      textoSalvarAtualizar = 'Atualizar';
    }
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('$textoSalvarAtualizar anotação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título',
              ),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Digite a descriçao',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: ()=> Navigator.pop(context),
              child: const Text('Cancelar'),
          ),ElevatedButton(
            onPressed: (){
              _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
              Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  _formatarData(String data){
    initializeDateFormatting('pt_BR');
    var formatar = DateFormat('dd/MM/y H:m:s');
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatar.format(dataConvertida);
    return dataFormatada;
  }

  @override
  void initState() {
    _listarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Anotações'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: (context, index){
                  final item = _anotacoes[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.titulo!),
                      subtitle: Text('${_formatarData(item.data!)} - ${item.descricao!}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                              onTap: (){
                                _exibirTelaCadastro(anotacao: item);
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.edit, color: Colors.green,
                                ),
                              ),
                          ),
                          GestureDetector(
                            onTap: (){
                              _removerAnotacao(item.id!);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(Icons.remove_circle, color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: (){
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
