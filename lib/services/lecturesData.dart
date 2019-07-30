import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
  
  class Lecture {
    final String id;
    final String title;
    final String startTime;
    final String endTime;
    final String startDate;
    final String location;
    final List speakers;

    Lecture(this.id, this.title, this.startDate, this.startTime, this.endTime, this.location, this.speakers);

  }

    final List<Lecture> lectures = [];

    Future fetchData() async {
      var data =
          await http.get('https://gramadosummit.com/api/v1/lectures?includeFields=_id,title,startTime,endTime,startDate,location,break,_speakers');
      var jsonData = json.decode(data.body);
      var results = jsonData['results'];
      for (var item in results) {
        Lecture data = Lecture(
          item['_id'],
          item['title'],
          item['startDate'],
          item['startTime'],
          item['endTime'],
          item['location'],
          item['_speakers'],
        );
      lectures.add(data);
      }
      var grouped = groupBy(lectures, (obj) => obj.startTime).values.toList();
      return grouped;
  
    }

    defineLectures(array, String currentDate, String stage) {
      var temp = [];
      array.forEach((item) => {
        if (stage == 'all') {
          for (var i in item) {
            if (i.startDate == currentDate) {
              temp.add(i)
            }
          }
        }
        else if (stage == 'principal') {
          for (var i in item) {
            if (i.startDate == currentDate && i.location == stage) {
              temp.add(i)
            }
          }
        }
        else if (stage == 'share') {
          for (var i in item) {
            if (i.startDate == currentDate && i.location == stage) {
              temp.add(i)
            }
          }
        }
        else if (stage == 'comunidade') {
          for (var i in item) {
            if (i.startDate == currentDate && i.location == stage) {
              temp.add(i)
            }
          }
        }
      });

      var grouped = groupBy(temp, (obj) => obj.startTime).values.toList();
      return grouped;
      
    }