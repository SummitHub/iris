import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import '../models/lecture.dart';

class Lectures with ChangeNotifier {
  List<Lecture> lectures  = [];
  List<List<Lecture>> groupedLectures = [];
  List<List<Lecture>> filteredGroupedLectures = [];
  int selectedDay = 0;
  bool shouldFetchData = true;
  String currentDay = '2019-07-31';
  String currentWeekDay = 'Quarta';
  String dropdownValue = 'Todos os palcos';
  String currentStage ='all';
  Map<String, String> dropdownOptions = {'Todos os palcos':'all', 'Palco Getnet':'principal', 'Palco Share':'share', 'Palco Comunidade':'comunidade'};

  Lectures(){
    fetchInitialData();
  }
  
  Future fetchInitialData() async {
      print("Fetching Initial lectures data");
      var data = await http.get('https://gramadosummit.com/api/v1/lectures?includeFields=_id,title,startTime,endTime,startDate,location,break,_speakers');
      var jsonData = json.decode(data.body);
      var results = jsonData['results'];
      for (var item in results) {
        if (item['break'] != true) {
          lectures.add(Lecture(item));
        } else {
          continue;
        }
      }
      groupedLectures = groupBy(lectures, (obj) => obj.startDate).values.toList();
      filteredGroupedLectures = groupBy(lectures, (obj) => obj.startDate).values.toList();
      print("Lectures Data Fetched");
      shouldFetchData = false;
      notifyListeners();
  }

  filterByStage(String stageLabel) {
    print("Setting Stage to : " + stageLabel);
    dropdownValue = stageLabel;
    currentStage = dropdownOptions[stageLabel];
    if (currentStage == 'all') {
      filteredGroupedLectures = groupBy(lectures, (obj) => obj.startDate).values.toList();
    }
    else {
      groupedLectures.forEach((day) {
        filteredGroupedLectures[groupedLectures.indexOf(day)].clear();
        day.forEach((lec) { 
          if (lec.location == currentStage) {
            filteredGroupedLectures[groupedLectures.indexOf(day)].add(lec);
          } 
        });
      });
    }
    notifyListeners();
  }
}
