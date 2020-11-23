import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  _handleActiveBands( dynamic payload){

    this.bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Band Names', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.check_circle, color: Colors.blue[300],)
              : Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [
          if(bands.isNotEmpty)
            _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 10.0),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: Text('Delete Band', style: TextStyle(color: Colors.white,)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20.0),),
        onTap: () => socketService.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand(){

    final textController = TextEditingController();

    if(Platform.isAndroid){
      //Android
      return showDialog(
        context:context,
        builder: (_) => AlertDialog(
          title: Text('New band name'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
            )
          ],
        ),
      );
    } 

    showCupertinoDialog(
      context: context, 
      builder: (_) => CupertinoAlertDialog(
        title: Text('New band name'),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Add'),
            onPressed: () => addBandToList(textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Dismiss'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void addBandToList( String name){
    if(name.length > 1){
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {

    Map<String, double> dataMap = Map();

    bands.forEach((band) { 
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[200],
      Colors.blue[400],
      Colors.pink[200],
      Colors.pink[400],
      Colors.orange[200],
      Colors.orange[400],
    ];

    return Container(
      padding: EdgeInsets.only(top: 15.0, left: 15),
      width: double.infinity,
      height: 250,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        // chartRadius: MediaQuery.of(context).size.width / 2.0,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        // centerText: "HYBRID",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          // legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 0,
          chartValueStyle: TextStyle(color: Colors.black87)
        ),
      )
    );
  }

}