import 'timeable.dart';

class Comment with Timeable {

  int id;
  int userId;
  int postId;
  String username;
  String text;

  Comment({int id, int userId, int postId, String username, String text, int epochTime}) {
    this.id = id ?? 0;
    this.userId = userId ?? 0;
    this.postId = postId ?? 0;
    this.text = text ?? 'TEXT';
    this.username = username ?? 'USERNAME';
    this.epochTime = epochTime ?? 0;
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['owner'],
      postId: json['post'],
      text: json['text'],
      epochTime: (DateTime.parse(json['timestamp']).toUtc().millisecondsSinceEpoch/1000).round(),
      username: 'UNDEFINED_USERNAME'
    );
  }

  String getInPostTimeStamp() {
    if (this.isToday()) return getHHMM() + ' today';
    else if (this.isYesterday()) return getHHMM() + ' yesterday';
    else if (this.isThisYear()) return getHHMM() + ' ' + getDDMM();
    else return getHHMM() + ' ' + getDDMMYY();
  }

}