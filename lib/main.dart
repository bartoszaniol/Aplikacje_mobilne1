import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import "drawer.dart";

void main() {
  runApp(MyApp());
}

Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
  Map<String, dynamic> newMap = {};
  map.forEach((key, value) {
    newMap[key.toString()] = map[key];
  });
  return newMap;
}

Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
  Map<DateTime, dynamic> newMap = {};
  map.forEach((key, value) {
    newMap[DateTime.parse(key)] = map[key];
  });
  return newMap;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Kalendarz(),
    );
  }
}

class Kalendarz extends StatefulWidget {
  @override
  KalendarzState createState() => KalendarzState();
}

class KalendarzState extends State<Kalendarz> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _textController;
  SharedPreferences prefs;
  TextEditingController zmianaTextu;
  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _textController = TextEditingController();
    zmianaTextu = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initializeDateFormatting('pl_PL', null);
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(jsonDecode(prefs.getString("events") ?? "{}")));
    });
  }

  void _openBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return SingleChildScrollView(
          child: Container(
            // color: Colors.blueAccent,
            padding: EdgeInsets.all(10),
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(labelText: 'Tresc notatki'),
                ),
                SizedBox(
                  height: 180,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Wybrana Data',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('d-MM-y')
                              .format(_calendarController.selectedDay),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        if (_textController.text.isEmpty) return;
                        setState(() {
                          if (_events[_calendarController.selectedDay] !=
                              null) {
                            _events[_calendarController.selectedDay]
                                .add(_textController.text);
                          } else {
                            _events[_calendarController.selectedDay] = [
                              _textController.text
                            ];
                          }
                        });
                        prefs.setString(
                            "events", jsonEncode(encodeMap(_events)));
                        _textController.clear();
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.assignment_turned_in),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> zmiana(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Podaj tresc"),
            content: TextField(
              controller: zmianaTextu,
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  if (zmianaTextu.text != null) {
                    Navigator.of(context).pop(zmianaTextu.text.toString());
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Zatwierdz"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kalendarz"),
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.blue),
        child: NoteDrawer(_events),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/cos2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            TableCalendar(
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (date, events, holidays) {
                setState(() {
                  _selectedEvents = events;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                centerHeaderTitle: true,
              ),
              calendarStyle: CalendarStyle(
                todayColor: Colors.red[700],
                selectedColor: Theme.of(context).primaryColor,
                markersColor: Theme.of(context).shadowColor,
              ),
              events: _events,
              calendarController: _calendarController,
              locale: 'pl_PL',
              // events: _events,
            ),
            Container(
              height: 320,
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._selectedEvents.map(
                        (event) => Card(
                          color: Colors.blue[100],
                          elevation: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 230,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    event,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 200,
                              // ),
                              IconButton(
                                icon: Icon(
                                  Icons.drive_file_rename_outline,
                                  size: 25,
                                ),
                                onPressed: () {
                                  // print(_events[_calendarController.selectedDay
                                  //     .add(Duration(days: 3))]);
                                  // _events[_calendarController.selectedDay
                                  //         .add(Duration(days: 3))]
                                  //     .removeWhere(
                                  //         (element) => element == null);

                                  zmiana(context).then((value) {
                                    // print(value);

                                    setState(() {
                                      int index = _events[
                                              _calendarController.selectedDay]
                                          .indexWhere(
                                              (element) => element == event);
                                      _events[_calendarController.selectedDay]
                                          [index] = value;
                                    });
                                    prefs.setString("events",
                                        jsonEncode(encodeMap(_events)));
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_forever_rounded,
                                  size: 25,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _events[_calendarController.selectedDay]
                                        .remove(event);
                                  });
                                  prefs.setString(
                                      "events", jsonEncode(encodeMap(_events)));
                                },
                              )
                            ],
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openBottomSheet(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
