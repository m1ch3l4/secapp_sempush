import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'dart:convert';
import 'package:secapp_sempush/model/Idbean.dart';
import 'package:secapp_sempush/model/TechSupportModel.dart';
import 'package:secapp_sempush/utils/HexColor.dart';
import 'package:secapp_sempush/utils/ListViewMenu.dart';
import 'package:secapp_sempush/utils/OptionsSearch.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import '../constants.dart';

void main() => runApp(new Ticketsview());

class Ticketsview extends StatelessWidget {

  static const routeName = '/tickets';
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
            home: new TicketsPage(title: 'Tickets MovieDesk', user: snapshot.data),
          ) : CircularProgressIndicator());
        },
      ),
    );
  }
}

class TicketsPage extends StatefulWidget {
  TicketsPage({Key key, this.title,this.user}) : super(key: key);

  final String title;
  final Map<String, dynamic> user;

  @override
  _TicketsPageState createState() => new _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  List<TechSupportData> listModel = [];
  var loading = false;
  Idbean selected = OptionsSearch.defaultOpt;
  Future<Null> getData() async{
    setState(() {
      loading = true;
    });

    String urlApi = Constants.urlEndpoint+"tech/list/"+widget.user['id'].toString()+"/"+selected.number.toString();
    print("****URL API: ");
    print(urlApi);
    print("**********");

    final responseData = await http.get(Uri.parse(urlApi));    if(responseData.statusCode == 200){
      String source = Utf8Decoder().convert(responseData.bodyBytes);
      final data = jsonDecode(source);
      setState(() {
        for(Map i in data){
          listModel.add(TechSupportData.fromJson(i));
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
        child: ListViewMenu('tickets',widget.user,textTheme),
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
      children: <Widget>[
        for (int i=0; i<listModel.length; i++)
          getAlert(listModel[i].title, listModel[i].data, listModel[i].status,listModel[i].justify)
      ],
    ));
  }

  Widget getAlert(String title, String date, String event, String justify){
    return Card(
        child: Column(
          children: [
            ListTile(
                title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(date),
                leading: Icon(
                    Icons.dangerous,
                    color: HexColor(Constants.red)
                )),
            Divider(),
            ListTile(
              title: Text((event.compareTo("Aguardando")==0?event+(justify!=null?": "+justify:""):event),
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
          value: selected,
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
              selected = newValue;
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