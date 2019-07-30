class Meeting {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String startDate;
  final String location;
  final String hostId;
  final Map<String, bool> guests;

  Meeting(this.id, this.title, this.startDate, this.startTime, this.endTime, this.location, this.hostId, this.guests);


  

}