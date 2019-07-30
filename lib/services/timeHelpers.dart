import 'package:date_format/date_format.dart';

convertDateFromString(String strDate){
   DateTime date = DateTime.parse(strDate);
   return formatDate(date, [dd, '/', mm, '/', yyyy]);
}

convertTimeFromString(String strTime){
   DateTime time = DateTime.parse('0000-00-00T' + strTime + 'Z');
   return formatDate(time, [HH, ':', nn]);
}

convertDateTimeFromString(String strDate, String strTime) {
  DateTime dateTime = DateTime.parse(strDate + 'T' + strTime + '.000Z');
  return formatDate(dateTime, [dd, '/', mm, '/', yyyy, ' ' , HH, ':', nn]);
}

getTimeInterval(items) {
  String interval = '';
  List start = [];
  List end = [];
  for (var item in items) {
    start.add(item.startTime);
    end.add(item.endTime);
  }
  start.sort();
  end.sort();
  interval = convertTimeFromString(start[0]) + ' - ' + convertTimeFromString(end[end.length-1]); 
  return interval;
}

