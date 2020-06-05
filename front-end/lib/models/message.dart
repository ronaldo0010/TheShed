import 'package:cloud_firestore/cloud_firestore.dart';

import 'timeable.dart';

class Message with Timeable {

  int id;
  String text;
  int senderId;
  int receiverId;

  Message({int id, String text, int senderId, int receiverId, int epochTime}) {
    this.id = id ?? 0;
    this.text = text ?? 'TEXT';
    this.senderId = senderId ?? 0;
    this.receiverId = receiverId ?? 0;
    this.epochTime = epochTime ?? 0;
  }  

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      epochTime: json['epochTime'],
    );
  }

  factory Message.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return Message(
      text: snapshot['text'],
      senderId: snapshot['sender_id'],
      receiverId: snapshot['recip_id'],
      epochTime: snapshot['time'].seconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': this.text,
      'sender_id': this.senderId,
      'recip_id': this.receiverId,
      'time': Timestamp(this.epochTime,0)
    };
  }

  String getListTimeStamp() {    
    // if same day & month & year (i.e. if today) return HH:mm
    if (this.isToday()) {
      return getHHMM();
    // if yesterday, say yesterday
    } else if (this.isYesterday()) {
      return 'Yesterday';
    // if same year at least, return DD/MM
    } else if (this.isThisYear()) {
      return getDDMM();
    // if past year, return DD/MM/YY
    } else {
      return getDDMMYY();
    }
  }

  String getInChatTimeStamp() {   
    // if today
    if (this.isToday()) {
      return getHHMM();
    // if yesterday
    } else if (this.isYesterday()) {
      return getHHMM() + ' yesterday';
    // if this year
    } else if (this.isThisYear()) {
      return getHHMM() + '  ' + getDDMM();
    // else
    } else {
      return getHHMM() + '  ' + getDDMMYYYY();
    }
  }

  String get senderName => 'USERNAME';

  String toString() => 'Message: text=${this.text}, sender=${this.senderId}, recip=${this.receiverId}, time=??';

}