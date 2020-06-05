import 'timeable.dart';

class Post with Timeable {

  int id;
  String text;
  double latitude;
  double longitude;
  String locationname;
  int userId;
  String username; // for display purposes only
  int groupId;
  String groupname; // for display purposes only
  var categories = <String>[];
  String tag;

  Post({this.id, this.text, int epochTime, this.latitude, this.longitude, this.locationname, this.userId, this.username, this.groupId, this.groupname, this.tag}) {
    this.epochTime = epochTime;
  }

  String get prettyCategories => this.categories.join('  |  ');

  String getInFeedTimestamp() {
    // if today
    if (this.isToday()) {
      return getHHMM();
    // if yesterday
    } else if (this.isYesterday()) {
      return getHHMM() + ' yesterday';
    // if this year
    } else if (this.isThisYear()) {
      return getHHMM() + ' ' + getDDMM();
    // else
    } else {
      return getHHMM() + ' ' + getDDMMYYYY();
    }
  }

  String getInPostPageTimestamp() {
    // if today
    if (this.isToday()) {
      return getHHMM() + ' today';
    // if yesterday
    } else if (this.isYesterday()) {
      return getHHMM() + ' yesterday';
    // if this year
    } else if (this.isThisYear()) {
      return getHHMM() + ' ' + getDDMM();
    // else
    } else {
      return getHHMM() + ' ' + getDDMMYYYY();
    }
  }

}