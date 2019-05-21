import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Gerar chave da API no site: https://hgbrasil.com/status/finance/
const URL = "https://api.hgbrasil.com/finance?format=json&key=CHAVE-API";

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.amber,
      accentColor: Colors.amberAccent,
      brightness: Brightness.dark,
      hintColor: Colors.amber,
    ),
    title: "Conversor de Moedas",
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(URL);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _dolar;
  double _euro;

  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final realController = TextEditingController();

  _realChanged(String value){
    if (value.isEmpty) {
      _resetFields();
      return;
    }
    double real = double.parse(value);
    dolarController.text = (real / _dolar).toStringAsFixed(2);
    euroController.text = (real / _euro).toStringAsFixed(2);
  }
  _dolarChanged(String value){
    if (value.isEmpty) {
      _resetFields();
      return;
    }
    double dolar = double.parse(value);
    realController.text = (dolar * _dolar).toStringAsFixed(2);
    euroController.text = ((dolar * _dolar) / _euro).toStringAsFixed(2);
  }
  _euroChanged(String value){
    if (value.isEmpty) {
      _resetFields();
      return;
    }
    double euro = double.parse(value);
    realController.text = (euro * _euro).toStringAsFixed(2);
    dolarController.text = ((euro * _euro) / _dolar).toStringAsFixed(2);
  }

  _resetFields(){
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle = TextStyle(color: Colors.amber, fontSize: 25.0);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "\$ Conversor de Moedas \$",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.restore),
            color: Colors.white,
            onPressed: _resetFields,
          )
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // TODO: Handle this case.
              break;
            case ConnectionState.waiting:
              return mensagem(_textStyle, "Carregando dados...");
              break;
            case ConnectionState.active:
              return mensagem(_textStyle, "Ativo");
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return mensagem(_textStyle, "Erro ao carregar dados :-(");
              } else {
                _dolar = snapshot.data['results']['currencies']['USD']['buy'];
                _euro = snapshot.data['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextField(realController, "Reais", _textStyle, "R\$ ", _realChanged),
                        Divider(),
                        buildTextField(dolarController, "Dólares", _textStyle, "US\$ ", _dolarChanged),
                        Divider(),
                        buildTextField(euroController, "Euros", _textStyle, "€ ", _euroChanged),
                      ],
                    ));
              }
              break;
            default:
              if (snapshot.hasError) {
                return mensagem(_textStyle, "Erro ao carregar dados :-(");
              } else {
                return mensagem(_textStyle, "Funcionou Default :-)");
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(TextEditingController controller, String label,
    TextStyle textStyle, String prefix, Function onChange) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
    style: textStyle,
    cursorColor: Colors.amber,
    cursorWidth: 3,
    maxLength: 20,
    onChanged: onChange,
    decoration: InputDecoration(
        labelText: label,
        counterText: "",
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
  );
}

Widget mensagem(_textStyle, String mensagem) {
  return Center(
    child: Text(
      mensagem,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
    ),
  );
}
