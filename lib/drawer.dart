import "package:flutter/material.dart";
import 'package:intl/intl.dart';

class NoteDrawer extends StatefulWidget {
  final Map<DateTime, List<dynamic>> eventy;
  NoteDrawer(this.eventy);

  List<Map<String, List<dynamic>>> get wydarzenia {
    return List.generate(8, (index) {
      final dzien = DateTime.now().add(Duration(days: index));
      var dzionek = DateFormat('d-MM-y').format(dzien);
      List<dynamic> lista = [];
      eventy.forEach((key, value) {
        if (key.day == dzien.day &&
            key.weekday == dzien.weekday &&
            key.month == dzien.month) {
          lista = value;
        }
      });

      return {dzionek: lista};
    });
  }

  Widget halp(List<Map<String, List<dynamic>>> cosik) {
    List<String> wartosci = [];
    List<dynamic> coss = [];
    cosik.forEach((element) {
      element.forEach((key, value) {
        if (value.isNotEmpty) {
          wartosci.add(key);
          coss.add(value);
        }
      });
    });

    if (wartosci.isNotEmpty) {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: wartosci.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.blue[200],
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Text(
                      'Dzien ${wartosci[index]}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: coss[index].length,
                        itemBuilder: (BuildContext context, int indexx) {
                          return Center(
                            child: Text(
                              '${coss[index][indexx]}',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            );
          });
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Nie ma zadnych zaplanowanych wydarzen",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  NoteDrawerState createState() => NoteDrawerState();
}

class NoteDrawerState extends State<NoteDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.blue[300],
                height: 120,
                width: double.infinity,
                padding: EdgeInsets.only(top: 10, left: 5),
                alignment: Alignment.centerLeft,
                child: Center(
                  child: Text(
                    "Wydarzenia na obecny tydzien",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              widget.halp(widget.wydarzenia),
            ],
          ),
        ),
      ),
    );
  }
}
