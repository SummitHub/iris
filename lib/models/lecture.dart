class Lecture {
  final dynamic lectureObject;
  String id;
  String title;
  String startTime; //remover
  String endTime; //
  String startDate; //
  String location;
  List speakers;

  DateTime startDateTime;
  DateTime endDateTime;
  int durationInMinutes;

  Lecture(this.lectureObject){
    id = lectureObject['_id'];
    title = lectureObject['title'];
    startDate = lectureObject['startDate'];
    startTime = lectureObject['startTime'];
    endTime = lectureObject['endTime'];
    location = lectureObject['location'];
    speakers = lectureObject['_speakers'];
    startDateTime = DateTime.parse(startDate + ' ' + startTime);
    endDateTime = DateTime.parse(startDate + ' ' + endTime);
    durationInMinutes = startDateTime.difference(endDateTime).inMinutes;
    //print("Lecture :" + title + "; Begins: " + startDateTime.toString() + "; Ends: " + endDateTime.toString());
  }

  getSpeakersImages(speakers) {
    List temp = [];
    speakers.forEach((speaker) {
      temp.add('https://gramadosummit.com'+speaker['thumbnail']['items'][0]['_pieces'][0]['item']['attachment']['_urls']['full']);
    });
    return temp;
  }

/*   static getSpeakersNames(lecture) {
    String names = lecture.title+'\n\n';
    for (var i = 0; i < lecture.speakers.length; i++) {
      if (i != lecture.speakers.length-1) {
        names += lecture.speakers[i]['title']+'\n';
      } else {
        names += lecture.speakers[i]['title'];
      }
    }
    return names;
  }
 */


}