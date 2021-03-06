
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:secapp_sempush/model/Idbean.dart';
import 'package:secapp_sempush/utils/HexColor.dart';
import 'package:secapp_sempush/utils/ListViewMenu.dart';
import 'package:secapp_sempush/utils/OptionsSearch.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../constants.dart';
import '../model/AlertModel.dart';

void main() => runApp(new ElasticAlerts());

class ElasticAlerts extends StatelessWidget {

  static const routeName = '/elastic';
  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: FlutterSession().get("logged"),
        builder: (context,snapshot){
          return (snapshot.hasData ? new MaterialApp(
            title: 'TI & Segurança',
            theme: new ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: new ElasticPage(title: 'Alertas SIEM', user: snapshot.data),
          ) : CircularProgressIndicator());
        },
      ),
    );
  }
}

class ElasticPage extends StatefulWidget {
  ElasticPage({Key key, this.title,this.user}) : super(key: key);

  final String title;
  final Map<String, dynamic> user;

  @override
  _ElasticPageState createState() => new _ElasticPageState();
}

class _ElasticPageState extends State<ElasticPage> {
  List<AlertData> listModel = [];
  var loading = false;
  Idbean select = OptionsSearch.defaultOpt;

  Future<Null> getData() async{
    setState(() {
      loading = true;
    });

    String urlApi = Constants.urlEndpoint+"alert/elastic/"+widget.user['company_id'].toString()+"/"+select.number.toString();
    print("****URL API: ");
    print(urlApi);
    print("**********");

    final responseData = await http.get(Uri.parse(urlApi));    if(responseData.statusCode == 200){
      String source = Utf8Decoder().convert(responseData.bodyBytes);
      final data = jsonDecode(source);
      setState(() {
        for(Map i in data){
          listModel.add(AlertData.fromJson(i));
        }
        loading = false;
      });
    }
  }

  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return new Scaffold(
      appBar: AppBar(title: Text(widget.title),
          backgroundColor: HexColor(Constants.red)
      ),
      drawer: Drawer(
        child: ListViewMenu('elastic',widget.user,textTheme),
      ),
      body:  Container(
        padding: EdgeInsets.fromLTRB(10,10,10,0),
        width: double.maxFinite,
        child: loading ? Center (child: CircularProgressIndicator()) : getMain(),
      ),
    );
  }

  Widget getMain(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        optionsToShow(),
        listView(),
      ],
    );
  }
  Widget listView(){
    return Expanded(child: ListView(
      children: getChildren()
    ));
  }
  List<Widget> getChildren(){
    final df = new DateFormat('dd-MM-yyyy hh:mm a');
    final DateTime now = DateTime.now();
    final String formatada = df.format(now);
    List<Widget> lista = List<Widget>();
    if(listModel.length>0){
      for (int i = 0; i < listModel.length; i++)
        lista.add(getAlert(listModel[i].title, listModel[i].data, listModel[i].text));
    }else{
      lista.add(getAlert("Sem dados",formatada,"Sem informações para o período consultado"));
    }

      return lista;
  }
  Widget getAlert(String title, String date, String event){
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(date),
            leading: Icon(
            Icons.warning,
            color: HexColor(Constants.blue)
          )),
          Divider(),
          ListTile(
            title: Text(event,
            style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        ],
      )
    );
  }

  Widget optionsToShow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [Text("Período: ",style: TextStyle(
      color: HexColor(Constants.red),
      fontWeight: FontWeight.w800,
      fontSize: 20,
    ),
    ),
      DropdownButton<Idbean>(
        value: select,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: HexColor(Constants.red)),
        underline: Container(
          height: 2,
          color: HexColor(Constants.blue),
        ),
        onChanged: (Idbean newValue) {
          setState(() {
            select = newValue;
            listModel = [];
            getData();
          });
        },
        items: OptionsSearch.lstOptions.map((Idbean bean) {
          return  DropdownMenuItem<Idbean>(
            value: bean,
            child: Text(bean.text));}).toList(),
      )
    ],
    );
  }
}