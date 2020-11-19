import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Kansas', votes: 10),
    Band(id: '2', name: 'Héroes del Silencio', votes: 5),
    Band(id: '3', name: 'Rata Blanca', votes: 15),
    Band(id: '4', name: 'Vilma Palma', votes: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Band Names', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) => _bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction){
        print('direction: $direction');
        print('direction: ${band.id}');
        //TODO: llamar el borrado en el servidor
      },
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
        onTap: (){
        },
      ),
    );
  }

  addNewBand(){

    final textController = TextEditingController();

    if(Platform.isIOS){
      //Android
      return showDialog(
        context:context,
        builder: (context) {
          return AlertDialog(
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
          );
        },
      );
    } 

    showCupertinoDialog(
      context: context, 
      builder: (_) {
        return CupertinoAlertDialog(
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
        );
      },
    );
  }

  void addBandToList( String name){
    if(name.length > 1){
      this.bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {
      
      });
    }
    Navigator.pop(context);
  }

}