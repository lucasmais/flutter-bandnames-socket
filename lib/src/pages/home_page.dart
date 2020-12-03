import 'dart:io';

import 'package:bandnamesapp/src/models/band_model.dart';
import 'package:bandnamesapp/src/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // new Band(id: '1', name: 'Metallica', votes: 5),
    // new Band(id: '2', name: 'Queen', votes: 1),
    // new Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    // new Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.OnLine)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red[300],
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: bands.length,
              itemBuilder: (context, i) => bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  Widget bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(
          band.name,
        ),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                    child: Text('Add'),
                    textColor: Colors.blue,
                    elevation: 5,
                    onPressed: () => addBandToList(textController.text),
                  ),
                ],
              ));
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
                  child: Text('Add'),
                  isDefaultAction: true,
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  child: Text('Dismiss'),
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {
      // 'Flutter': 5,
      // 'React': 3,
      // 'Xamarin': 2,
      // 'Ionic': 2,
    };
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    return PieChart(
      dataMap: dataMap,
      chartValuesOptions: ChartValuesOptions(
          showChartValuesInPercentage: true, showChartValueBackground: true),
    );
    // return PieChart(
    //   dataMap: dataMap,
    //   animationDuration: Duration(milliseconds: 800),
    //   chartLegendSpacing: 32,
    //   chartRadius: MediaQuery.of(context).size.width / 3.2,
    //   // colorList: colorList,
    //   initialAngleInDegree: 0,
    //   chartType: ChartType.ring,
    //   ringStrokeWidth: 32,
    //   centerText: "HYBRID",
    //   legendOptions: LegendOptions(
    //     showLegendsInRow: false,
    //     legendPosition: LegendPosition.right,
    //     showLegends: true,
    //     legendShape: BoxShape.circle,
    //     legendTextStyle: TextStyle(
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    //   chartValuesOptions: ChartValuesOptions(
    //     showChartValueBackground: true,
    //     showChartValues: true,
    //     showChartValuesInPercentage: false,
    //     showChartValuesOutside: false,
    //   ),
    // );
  }
}
