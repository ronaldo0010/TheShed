import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart';
import 'package:rw334/models/comment.dart';
import 'package:location/location.dart';
import 'package:rw334/models/group.dart';
import 'package:rw334/models/post.dart';

var token;
List<dynamic> allUserPosts;
List<dynamic> allUserFeed;
List allFeed;
List allPosts;
String owner;
String globalUsername;
int userId;
Set<String> globalGroupsID = {};
Set<String> globalGroups = {};

List<String> getGlobalGroups() {
  List ls = globalGroups.toList();
  return ls;
}

List<String> getGlobalGroupsID() {
  List ls = globalGroupsID.toList();
  return ls;
}

Future makeComment(String txt, int pid) async {
  String url = "https://theshedapi.herokuapp.com/api/v1/Comments/";
  final res = await post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
    body: JsonEncoder().convert(
      {
        "text": txt,
        "post": pid,
        "owner": userId,
      },
    ),
  );
  return null;
}

Future signedUp(String username, String email, String psw) async {
  final String url = "https://theshedapi.herokuapp.com/api/registration/";

  final response = await post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JsonEncoder().convert(
      {
        "username": username,
        "password": psw,
        "email": email,
        "groups": [51],
      },
    ),
  );

  if (response.statusCode == 200) {
    var resBody = json.decode(response.body);
    return null;
  } else {
    //print(response.statusCode);
    return null;
  }
}

//returns userID of user with this username
Future userID(String user) async {
  String url = "https://theshedapi.herokuapp.com/api/v1/Users/?username=";
  url = url + user;
  List<dynamic> list;
  int id;

  final response = await get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  });

  if (response.statusCode == 200) {
    list = json.decode(response.body);
  }
  if (list.length == 0) return null;
  
  id = list[0]["id"];
  return id;
}

Future<String> getUsernameFromID(int id) async {
  String url = "https://theshedapi.herokuapp.com/api/v1/Users/?id=";
  url = url + '${id.toString()}';
  List<dynamic> list;
  String res;

  final response = await get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  });

  if (response.statusCode == 200) {
    list = json.decode(response.body);
    res = list[0]['username'];
    return res;
  } else {
    return 'DEF_USERNAME';
  }
}

// returns user auth-token
Future loggedIn(String usr, String psw) async {
  String apiURL = "https://theshedapi.herokuapp.com/api-token-auth/";

  Response response =
      await post(apiURL, body: {"username": usr, "password": psw});
  if (response.statusCode == 200) {
    token = json.decode(response.body);
    token = token["token"];

    userId = await userID(usr);
    //print(userId);
    makeUser();
    return true;
  }
    //print(response.statusCode);
  return false;

}

Future<void> makeUser() async {
  globalUsername = await getUsernameFromID(userId);
  getAllUserPosts();
  getUserFeed('Time', 'Asc');
}

/// Get a List<Group> of all the groups that exist.
Future<List<Group>> getAllGroups() async {
  List data = [];
  List<Group> results = [];
  String url = "https://theshedapi.herokuapp.com/api/v1/groups/";
  final response = await get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  });
  if (response.statusCode == 200) {
    data = json.decode(response.body);
  }
  for (int i = 0; i < data.length; i++) {
    // evaluating data[j]
    results.add(
      Group(
        id: data[i]['id'] ?? 'DEF_ID',
        epochTime: convertTime(data[i]['date_created']) ?? 'DEF_TIME',
        name: data[i]['name'] ?? 'DEF_NAME',
        tag: data[i]['tag'] ?? '(no tags)',
        description: data[i]['description'] ?? 'DEF_DESC',
        createdBy: data[i]['created_by'],
      ),
    );
  }

  return results;
}

/// Get the name of the location at the given coordinates.
Future<String> getLocationFromCoords(double lat, double long) async {
  if (lat > 90.0 || lat < -90.0 || long > 180.0 || long < -180.0) {
    return '!!!';
  }
  try {
    final coordinates = Coordinates(lat, long);
    List<Address> addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // print('${addresses.first.locality}');
    return '${addresses.first.locality}, ${addresses.first.countryCode}';
  } on Exception catch (e) {
    //print(e.toString());
    return '???';
  }
}

/// Get the name of location the device is currently at.
Future<String> getCurrentLocationName() async {
  Location location = new Location();

  PermissionStatus _permissionGranted;
  LocationData _locationData;
  _locationData = await location.getLocation();
  double lat;
  double long;

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.DENIED) {
    _permissionGranted = await location.requestPermission();
    // Stellenbosch's location
    lat = -33.93;
    long = 18.86;
  } else {
    lat = _locationData.latitude;
    long = _locationData.longitude;
  }

  return await getLocationFromCoords(lat, long);
}

/// Makes a post with the given text in the given group.
Future makePost(String txt, String grp) async {
  //print('Making post \"$txt\" in \"$grp\"');
  Location location = new Location();

  PermissionStatus _permissionGranted;
  LocationData _locationData;
  _locationData = await location.getLocation();
  double lat;
  double long;

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.DENIED) {
    _permissionGranted = await location.requestPermission();
    // Stellenbosch's location
    lat = -33.93;
    long = 18.86;
  } else {
    lat = _locationData.latitude;
    long = _locationData.longitude;
  }

  String locationName = await getLocationFromCoords(lat, long);
  print(locationName);

  String url = "https://theshedapi.herokuapp.com/api/v1/posts/";
  // var temp = getGlobalGroups();
  // var temp2 = getGlobalGroupsID();
  // String group = temp2[temp.indexOf(grp)];
  // print(group);

  String group = await getGroupUrl(grp);

  final response = await post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Token " + token
      },
      body: JsonEncoder().convert({"text": txt, "latitude": lat, "longitude": long, "group": group}));
  //print(response.statusCode);
}

/// Get all the posts made by the current user.
Future<List<Post>> getAllUserPosts() async {
  List data;
  List<Post> results = [];
  String url =
      "https://theshedapi.herokuapp.com/api/v1/posts/?owner=" + "$userId";
  final response = await get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  });
  if (response.statusCode == 200) {
    data = json.decode(response.body);
  }
  for (int j = 0; j < data.length; j++) {
    // evaluating data[j]
    String locationName =
        await getLocationFromCoords(data[j]['latitude'], data[j]['longitude']);
    results.add(
      Post(
        id: data[j]['id'],
        longitude: data[j]['longitude'],
        latitude: data[j]['latitude'],
        text: data[j]['text'],
        epochTime: convertTime(data[j]['timestamp']),
        tag: data[j]['tag'],
        username: data[j]['owner'],
        groupname: data[j]['group_name'],
        locationname: locationName,
      ),
    );
  }
  allPosts = results;

  return results;
}

/// Get all the comments on the post with the given ID.
Future<List<Comment>> getCommentsOnPost(int postID) async {
  List<Comment> results = [];

  String url =
      'https://theshedapi.herokuapp.com/api/v1/Comments/?post=${postID.toString()}';
  var response = await get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  });
  if (response.statusCode != 200) {
    return [];
  }
  var data = json.decode(response.body);
  for (int i = 0; i < data.length; i++) {
    results.add(
      Comment(
        id: data[i]['id'],
        text: data[i]['text'],
        epochTime: convertTime(data[i]['timestamp']),
        postId: postID,
        username: data[i]['owner'],
        // username: 'UNDEFINED_USERNAME',
      ),
    );
  }
  results.sort((a, b) => -b.epochTime.compareTo(a.epochTime));
  return results;
}

/// returns all the posts the current user is interested in
Future<List<Post>> getUserFeed(String sortKey, String sortOrder) async {
  var data;
  List<int> groups;
  var temp;
  List<Post> results = [];

  String url = "https://theshedapi.herokuapp.com/api/v1/Users/?id=" + "$userId";
  var response = await get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  });
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    //temp =
    groups = new List<int>.from(data[0]["groups"]);
    // groups = data[0]["groups"];
    temp = "https://theshedapi.herokuapp.com/api/v1/groups/";
    for (int i = 0; i < groups.length; i++) {
      var gid = groups[i];
      globalGroupsID.add(temp + "$gid" + '/');
    }

    temp = null;
  }

  for (int i = 0; i < groups.length; i++) {
    url = "https://theshedapi.herokuapp.com/api/v1/posts/?group=";
    temp = groups[i];
    url = url + "$temp";

    response = await get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Token " + token
      },
    );

    data = json.decode(response.body);

    for (int j = data.length - 1; j >= 0; j--) {
      // evaluating data[j]

      // String username = await getUsernameFromID(data[j]['owner_id']);
      globalGroups.add(data[j]["group_name"]);
      String locationName = await getLocationFromCoords(
          data[j]['latitude'], data[j]['longitude']);
      results.add(
        Post(
          longitude: data[j]['longitude'],
          latitude: data[j]['latitude'],
          text: data[j]['text'],
          epochTime: convertTime(data[j]['timestamp']),
          tag: data[j]['tag'],
          username: data[j]['owner'],
          locationname: locationName,
          groupname: data[j]['group_name'],
          id: data[j]['id'],
          userId: data[j]['owner_id'],
        ),
      );
    }
  }

  // sort
  int sortOrderNegator = sortOrder == 'Asc' ? 1 : -1;
  switch (sortKey) {
    case 'Time':
      results.sort((a, b) => -sortOrderNegator * a.epochTime.compareTo(b.epochTime));
      break;
    case 'Location':
      results.sort((a, b) => sortOrderNegator * a.locationname.toLowerCase().compareTo(b.locationname.toLowerCase()));
      break;
    case 'User':
      results.sort((a, b) => sortOrderNegator * a.username.toLowerCase().compareTo(b.username.toLowerCase()));
      break;
    case 'Category':
      results.sort((a, b) => sortOrderNegator * a.tag.toLowerCase().compareTo(b.tag.toLowerCase()));
      break;
    default:
      break;
  }

  allFeed = results;
  //print(globalGroupsID);
  //print(globalGroups);
  return results;
}

Future<bool> updateProfile(String newUsr) async {
  String url = "https://theshedapi.herokuapp.com/api/v1/Users/";
  url = url + "$userId" + '/';
  var response = await patch(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
    body: JsonEncoder().convert(
      {
        "username": newUsr,
      },
    ),
  );

  if (response.statusCode != 200) {
    return false;
  }
  return true;
}

int convertTime(String time) {
  var parsedDate = DateTime.parse(time);
  int epoch = (parsedDate.toUtc().millisecondsSinceEpoch / 1000).round();
  return epoch;
}

Future<int> deleteGroup(String name) async{
  String url = "https://theshedapi.herokuapp.com/api/v1/groups/?name=$name";
  var temp;
  int id;
  var res = await get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
  );
  temp = json.decode(res.body);
  id = temp[0]["id"] as int;
  url = "https://theshedapi.herokuapp.com/api/v1/groups/$id/";
  print(url);

  res = await delete(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  });
  print(res.statusCode);

  return res.statusCode;

}

Future<int> makeGroup(String name, String desc, String tag) async {
  String url = "https://theshedapi.herokuapp.com/api/v1/groups/";
  var response = await post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
    body: JsonEncoder().convert({
      "name": name,
      "description": desc,
      "tag": tag
    }),
  );

  return response.statusCode;
}

Future<int> joinGroup(String grp) async {
  //url = na group
  String pUrl = "https://theshedapi.herokuapp.com/api/v1/Users/$userId/";

  var groupIdResponse = await get(
    'https://theshedapi.herokuapp.com/api/v1/groups/?name=$grp',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
  );

  if (groupIdResponse.statusCode != 200) return groupIdResponse.statusCode;
  var data = json.decode(groupIdResponse.body);
  print('Data:  $data');

  int gid = data[0]['id'];
  print('Group ID to add:  $gid');

  var userResponse = await get(
    'https://theshedapi.herokuapp.com/api/v1/Users/?id=$userId',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
  );

  if (userResponse.statusCode != 200) return userResponse.statusCode;
  data = json.decode(userResponse.body);

  List<dynamic> oldListOfIDs = data[0]['groups'];
  var newListOfIDs = oldListOfIDs;
  if (!newListOfIDs.contains(gid)) newListOfIDs.add(gid);

  print('New list of gids:  ${newListOfIDs.toString()}');

  var response = await patch(
    pUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
    body: JsonEncoder().convert(
      {
        "groups": newListOfIDs
      },
    ),
  );
  globalGroupsID.add('https://theshedapi.herokuapp.com/api/v1/groups/$gid/');
  globalGroups.add(grp);
  return response.statusCode;
}

Future<int> leaveGroup(String grp) async {
  //url = na group
  String pUrl = "https://theshedapi.herokuapp.com/api/v1/Users/$userId/";

  var groupIdResponse = await get(
    'https://theshedapi.herokuapp.com/api/v1/groups/?name=$grp',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
  );
  if (groupIdResponse.statusCode != 200) return groupIdResponse.statusCode;
  var data = json.decode(groupIdResponse.body);   // json of all groups matching groupname=grp  
  print('Data:  $data');

  int gid = data[0]['id']; // group id to remove
  print('Group ID to remove:  $gid');

  var userResponse = await get(
    'https://theshedapi.herokuapp.com/api/v1/Users/?id=$userId',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
  );

  if (userResponse.statusCode != 200) return userResponse.statusCode;
  data = json.decode(userResponse.body); // json of all users matching id=userId

  List<dynamic> oldListOfIDs = data[0]['groups'];   // all groups user is member of
  var newListOfIDs = oldListOfIDs;
  bool removed = newListOfIDs.remove(gid);

  print('New list of gids:  ${newListOfIDs.toString()}');

  var response = await patch(
    pUrl,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Token " + token
    },
    body: JsonEncoder().convert(
      {
        "groups": newListOfIDs
      },
    ),
  );
  globalGroupsID.remove('https://theshedapi.herokuapp.com/api/v1/groups/$gid/');
  globalGroups.remove(grp);
  return response.statusCode;
}

int getGid(String gUrl) {
  print(gUrl);
  String thing = "https://theshedapi.herokuapp.com/api/v1/groups/";
  var split_ =  gUrl.split(thing);
  var temp = split_[1];
  split_ = temp.split("/");
  temp = split_[0];
  int res = int.parse(temp);
  return res;
}

Future <int> deleteAccount() async{
  String url = "https://theshedapi.herokuapp.com/api/v1/Users/$userId/";

  var resp = await delete(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  }, );
  print(resp.statusCode);
  return resp.statusCode;
}

Future<String> getGroupUrl(String grp) async{
  String res = "";
  String url = "https://theshedapi.herokuapp.com/api/v1/groups/?name=$grp";

  var resp = await get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': "Token " + token
  }, );

  var data = json.decode(resp.body);
  int id = data[0]["id"];
  res = "https://theshedapi.herokuapp.com/api/v1/groups/$id/";

  return res;
}